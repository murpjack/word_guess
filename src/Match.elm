module Match exposing (match)

import List.Extra as List
import Types exposing (Ptn(..))


match : String -> String -> List (Ptn Char)
match answer guess =
    let
        als =
            String.toList answer

        gls =
            String.toList guess

        cart : List ( Char, Char )
        cart =
            List.map2 Tuple.pair als gls

        decr : Char -> List ( Char, Int ) -> List ( Char, Int )
        decr k =
            List.map
                (\( c, n ) ->
                    if k == c && n > 0 then
                        ( k, n - 1 )

                    else
                        ( c, n )
                )
    in
    List.reverse <|
        Tuple.first <|
            List.foldl
                (\( a, g ) ( acc, remainAns ) ->
                    if a == g then
                        ( Exact g :: acc, remainAns )

                    else
                        case findSnd (Tuple.first >> (==) g) remainAns of
                            Just rInAns ->
                                let
                                    exactMatches =
                                        List.count
                                            (\( la, lg ) -> la == g && la == lg)
                                            cart
                                in
                                if rInAns - exactMatches > 0 then
                                    ( Present g :: acc, decr g remainAns )

                                else
                                    ( Absent g :: acc, remainAns )

                            Nothing ->
                                ( Absent g :: acc, remainAns )
                )
                ( [], List.frequencies als )
                cart


findSnd :
    (( key, val ) -> Bool)
    -> List ( key, val )
    -> Maybe val
findSnd p =
    Maybe.map Tuple.second << List.find p
