module Utils exposing (match)

import List.Extra as List
import Triple
import Types exposing (Ptn(..))


match : String -> String -> List (Ptn Char)
match answer guess =
    let
        guessC =
            String.toList guess

        answerC =
            String.toList answer
    in
    -- TODO: ?? Possible performance improvement around reversing str
    List.reverse <|
        Triple.first <|
            List.foldl
                (\c ( ls, wd, ans ) ->
                    if List.isEmpty wd || List.isEmpty ans then
                        ( ls, [], [] )

                    else
                        let
                            ( w, ws ) =
                                List.splitAt 1 wd
                        in
                        case List.head w of
                            Just i ->
                                if i == c then
                                    ( Exact c :: ls, ws, List.remove c ans )

                                else if List.member c ans then
                                    ( Present c :: ls, ws, List.remove c ans )

                                else
                                    ( Absent c :: ls, ws, ans )

                            Nothing ->
                                ( ls, wd, ans )
                )
                ( [], answerC, answerC )
                guessC
