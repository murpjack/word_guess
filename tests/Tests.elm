module Tests exposing (..)

import Expect
import Test exposing (..)
import Types exposing (Ptn(..))
import Utils exposing (match)


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
                in
                Expect.all
                    [ \_ ->
                        Expect.equal (matchWith guess1) expect1
                    , \_ ->
                        Expect.equal (matchWith guess2) expect2
                    , \_ ->
                        Expect.equal (matchWith guess3) expect3
                    ]
                    ()
        ]
