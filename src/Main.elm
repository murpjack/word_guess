module Main exposing (..)

import Browser
import Debug exposing (toString)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Attrs
import Json.Decode as Decode
import List.Extra as List
import Types exposing (Model, Msg(..), Ptn(..))
import Utils exposing (match)


words : List String
words =
    [ "water" ]


answer : String
answer =
    "water"


maxGuesses : Int
maxGuesses =
    5


init : Decode.Value -> ( Model, Cmd Msg )
init _ =
    ( { currentGuess = ""
      , guesses = []
      , played = []
      , won = 0
      , message = ""
      , history = List.repeat maxGuesses 0
      , winStreakCurrent = 0
      , winStreakBest = 0
      }
    , Cmd.none
    )



---- PROGRAM ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitGuess ->
            -- FIXME: Refactor me to use a random word from a long list
            case List.head words of
                Just w ->
                    if model.currentGuess /= w && List.length model.guesses + 1 == maxGuesses then
                        ( { model
                            | message =
                                "The correct answer is " ++ answer ++ ". Try again tomorrow"
                            , guesses = model.guesses ++ [ model.currentGuess ]
                            , currentGuess = ""
                            , played = w :: model.played
                            , winStreakCurrent = 0
                          }
                        , Cmd.none
                        )

                    else if model.currentGuess == w then
                        ( { model
                            | message = "yay"
                            , guesses = model.guesses ++ [ model.currentGuess ]
                            , history = List.updateAt (List.length model.guesses) ((+) 1) model.history
                            , won = model.won + 1
                            , played = w :: model.played
                            , winStreakCurrent = model.winStreakCurrent + 1
                            , winStreakBest =
                                if model.winStreakCurrent + 1 > model.winStreakBest then
                                    model.winStreakCurrent + 1

                                else
                                    model.winStreakBest
                          }
                        , Cmd.none
                        )

                    else
                        ( { model
                            | message = ""
                            , currentGuess = ""
                            , guesses = model.guesses ++ [ model.currentGuess ]
                          }
                        , Cmd.none
                        )

                Nothing ->
                    ( { model
                        | message = "impossible"
                      }
                    , Cmd.none
                    )

        TypeLetter g ->
            ( { model
                | currentGuess = g
              }
            , Cmd.none
            )


main : Program Decode.Value Model Msg
main =
    Browser.document
        { view = view
        , init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        }



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "appy"
    , body = body model
    }


body : Model -> List (Html Msg)
body m =
    let
        found =
            List.member answer m.guesses

        attempts =
            List.map
                (\n ->
                    case List.getAt n m.guesses of
                        Just a ->
                            if a == answer then
                                (renderGuess << match answer) a

                            else
                                (renderGuess << match answer) a

                        Nothing ->
                            if n == List.length m.guesses && not found then
                                attempt { value = m.currentGuess, disabled = False }

                            else
                                Html.div []
                                    (List.repeat 5 (Html.span [] [ Html.text "_" ]))
                )
            <|
                List.range 0 (maxGuesses - 1)
    in
    [ Html.div [] attempts
    , details m
    , Html.text m.message
    ]


attempt : InputState -> Html Msg
attempt s =
    Html.div [ Attrs.class "attempt" ]
        [ Html.input [ Attrs.value s.value, Attrs.disabled s.disabled, Attrs.onInput TypeLetter ] []
        , Html.button [ Attrs.disabled s.disabled, Attrs.onClick SubmitGuess ] [ Html.text "Enter" ]
        ]


renderGuess : List (Ptn Char) -> Html Msg
renderGuess =
    Html.div []
        << List.map
            (\ptn ->
                case ptn of
                    Exact c ->
                        Html.span [ Attrs.style "color" "green" ] [ Html.text (String.fromChar c) ]

                    Present c ->
                        Html.span [ Attrs.style "color" "orangered" ] [ Html.text (String.fromChar c) ]

                    Absent c ->
                        Html.span [] [ Html.text (String.fromChar c) ]
            )


type alias InputState =
    { disabled : Bool
    , value : String
    }


details : Model -> Html Msg
details s =
    Html.div []
        [ Html.div [] [ Html.text ("guesses so far: " ++ (List.length s.guesses |> toString)) ]
        , Html.div [] [ Html.text ("won: " ++ toString s.won) ]
        , Html.div [] [ Html.text ("played: " ++ (List.length s.played |> toString)) ]
        , Html.div [] [ Html.text ("history: " ++ toString s.history) ]
        ]
