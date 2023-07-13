module Main exposing (..)

import Browser
import Debug exposing (toString)
import Flags
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Attrs
import Json.Decode as Decode
import List.Extra as List
import Maybe.Extra as Maybe
import Types exposing (Model, Msg(..), Ptn(..))
import Utils exposing (match)
import Words exposing (words)


maxGuesses : Int
maxGuesses =
    5


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        f =
            Decode.decodeValue Flags.decode flags |> Result.withDefault Flags.default
    in
    ( { currentGuess = ""
      , answer =
            Maybe.andThen
                (\randomidx -> List.getAt randomidx words)
                f.random
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
            case model.answer of
                Just ans ->
                    if model.currentGuess /= ans && List.length model.guesses + 1 == maxGuesses then
                        ( { model
                            | message =
                                "The correct answer is " ++ ans ++ ". Try again tomorrow"
                            , guesses = model.guesses ++ [ model.currentGuess ]
                            , currentGuess = ""
                            , played = ans :: model.played
                            , winStreakCurrent = 0
                          }
                        , Cmd.none
                        )

                    else if model.currentGuess == String.toUpper ans then
                        ( { model
                            | message = "yay"
                            , guesses = model.guesses ++ [ model.currentGuess ]
                            , history = List.updateAt (List.length model.guesses) ((+) 1) model.history
                            , won = model.won + 1
                            , played = ans :: model.played
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

        TypeLetter inputStr ->
            ( { model
                | currentGuess =
                    if List.all Char.isAlpha <| String.toList inputStr then
                        String.toUpper inputStr

                    else
                        model.currentGuess
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
            m.answer
                |> Maybe.map (\ans -> List.member ans m.guesses)
                |> Maybe.withDefault False

        attempts =
            case m.answer of
                Just answer ->
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

                Nothing ->
                    [ Html.text "There is no answer!!?" ]
    in
    [ Html.div [] attempts
    , details m
    , Html.text (m.message ++ toString m.answer)
    ]


attempt : InputState -> Html Msg
attempt s =
    Html.div [ Attrs.class "attempt" ]
        [ Html.input [ Attrs.maxlength 5, Attrs.value s.value, Attrs.disabled s.disabled, Attrs.onInput TypeLetter ] []
        , Html.button [ Attrs.disabled (s.disabled || String.length s.value < 5), Attrs.onClick SubmitGuess ] [ Html.text "Enter" ]
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
