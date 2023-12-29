module Match exposing (match)

import List.Extra as List
import Types exposing (Ptn(..))


{-|

    Given a pair of equal length strings - in this case answer and guess,
    indicate how close the guesser's guessed guess was.
    ie. Mark each letter with a Pattern type and use that type to change the colour of the letter.
    This will no doubt propell the guesser on to great things.

    Noteworthy, answer and guess is sewn together in a cartesian pair, cart.
    This means exact pairs are compared without using indexes.
    Perhaps indexes would make the code more performant? In any case...

    Possible cases here include:
        - letter in guess is an exact match
        - letter in guess is not an exact match but is present in another position [1]
        - letter in guess does not appear in the answer.

    [1] No more than the number of like-letters in answer should change colour in the display.
        Matches should be coloured from left to right.

-}
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
