module Tests exposing (..)

import Expect
import Main exposing (attempt, maxGuesses)
import Match exposing (match)
import Test exposing (..)
import Test.Html.Query as Query
import Test.Html.Selector exposing (disabled, tag)
import Types exposing (Ptn(..))
import Words exposing (words)


all : Test
all =
    describe "All tests"
        [ test "#12 Highlighting not working as expected" <|
            \_ ->
                let
                    answer =
                        "water"

                    matchWith =
                        match answer

                    exact =
                        List.map Exact <| String.toList answer

                    guess1 =
                        "wheat"

                    expect1 =
                        [ Exact 'w', Absent 'h', Present 'e', Present 'a', Present 't' ]

                    guess2 =
                        "earth"

                    expect2 =
                        [ Present 'e', Exact 'a', Present 'r', Present 't', Absent 'h' ]

                    guess3 =
                        "weave"

                    expect3 =
                        [ Exact 'w', Present 'e', Present 'a', Absent 'v', Absent 'e' ]

                    guess4 =
                        "error"

                    expect4 =
                        [ Present 'e', Absent 'r', Absent 'r', Absent 'o', Exact 'r' ]
                in
                Expect.all
                    [ \_ ->
                        Expect.equalLists (matchWith answer) exact
                    , \_ ->
                        Expect.equalLists (matchWith guess1) expect1
                    , \_ ->
                        Expect.equalLists (matchWith guess2) expect2
                    , \_ ->
                        Expect.equalLists (matchWith guess3) expect3
                    , \_ ->
                        Expect.equalLists (matchWith guess4) expect4
                    ]
                    ()
        , test "#9 Game over if max guesses reached" <|
            \_ ->
                let
                    maxGuesses =
                        5

                    guesses =
                        [ "abcde", "abcde", "abcde", "abcde", "abcde" ]

                    inputState =
                        { value = "noway"
                        , disabled = List.length guesses == maxGuesses
                        }
                in
                Expect.all
                    [ \el ->
                        el
                            |> Query.fromHtml
                            |> Query.children [ tag "input" ]
                            |> Query.each (Query.has [ disabled True ])
                    , \el ->
                        el
                            |> Query.fromHtml
                            |> Query.children [ tag "button" ]
                            |> Query.each (Query.has [ disabled True ])
                    ]
                    (attempt inputState)
        , test "#10 Add a list of words" <|
            \_ ->
                Expect.all
                    [ \wds -> Expect.greaterThan 0 (List.length wds)
                    , \wds ->
                        let
                            wordsAreAll5LettersLong =
                                List.all ((==) 5 << String.length) wds
                        in
                        Expect.equal True wordsAreAll5LettersLong
                    ]
                    words
        ]
