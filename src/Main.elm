module Main exposing (..)

import Browser
import Flags
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Attrs
import Json.Decode as Decode
import List.Extra as List
import Match exposing (match)
import Ports as Ports
import Types exposing (Model, Msg(..), Ptn(..), Tried(..))
import Words exposing (alphabet, words)


maxGuesses : Int
maxGuesses =
    5


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        f =
            Decode.decodeValue Flags.decode flags
                |> Result.withDefault Flags.default
    in
    ( { answer =
            case List.getAt f.idx words of
                Just a ->
                    String.toUpper a

                Nothing ->
                    "ERROR"
      , currentGuess = ""
      , guesses = f.guesses
      , tried = getTriedChars f.guesses
      , history =
            case f.history of
                [] ->
                    [ 0, 0, 0, 0, 0, 0 ]

                -- head is games not won
                h ->
                    h
      , played = List.foldr (\v acc -> acc + v) 0 f.history
      , won =
            case f.history of
                [] ->
                    0

                _ :: xs ->
                    List.foldr (\v acc -> acc + v) 0 xs
      , winStreakCurrent = f.winStreakCurrent
      , winStreakBest = f.winStreakBest
      }
    , Cmd.none
    )


getTriedChars : List String -> List Tried
getTriedChars guesses =
    let
        gchars : List Char
        gchars =
            List.map String.toList guesses
                |> List.concat
                |> List.unique
    in
    List.foldr
        (\c acc ->
            if List.member c gchars then
                Tried True c :: acc

            else
                Tried False c :: acc
        )
        []
        (String.toList alphabet)



---- PROGRAM ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitGuess ->
            if model.currentGuess /= model.answer && List.length model.guesses + 1 == maxGuesses then
                ( { model
                    | guesses = model.guesses ++ [ model.currentGuess ]
                    , currentGuess = ""
                    , played = model.played + 1
                    , history = List.updateAt 0 ((+) 1) model.history
                    , winStreakCurrent = 0
                  }
                , Ports.sendDataOutside
                    (Ports.PersistData
                        { idx =
                            case List.findIndex ((==) model.answer) words of
                                Just i ->
                                    i

                                Nothing ->
                                    0
                        , guesses = model.guesses ++ [ model.currentGuess ]
                        , history = List.updateAt 0 ((+) 1) model.history
                        , winStreakCurrent = 0
                        , winStreakBest = model.winStreakBest
                        }
                    )
                )

            else if model.currentGuess == model.answer then
                ( { model
                    | guesses = model.guesses ++ [ model.currentGuess ]
                    , tried = getTriedChars (model.currentGuess :: model.guesses)
                    , history = List.updateAt (List.length model.guesses + 1) ((+) 1) model.history
                    , won = model.won + 1
                    , played = model.played + 1
                    , winStreakCurrent = model.winStreakCurrent + 1
                    , winStreakBest =
                        if model.winStreakCurrent + 1 > model.winStreakBest then
                            model.winStreakCurrent + 1

                        else
                            model.winStreakBest
                  }
                , Ports.sendDataOutside
                    (Ports.PersistData
                        { idx =
                            case List.findIndex ((==) model.answer) words of
                                Just i ->
                                    i

                                Nothing ->
                                    0
                        , guesses = model.guesses ++ [ model.currentGuess ]
                        , history = List.updateAt (List.length model.guesses + 1) ((+) 1) model.history
                        , winStreakCurrent = model.winStreakCurrent + 1
                        , winStreakBest =
                            if model.winStreakCurrent + 1 > model.winStreakBest then
                                model.winStreakCurrent + 1

                            else
                                model.winStreakBest
                        }
                    )
                )

            else
                ( { model
                    | currentGuess = ""
                    , tried = getTriedChars (model.currentGuess :: model.guesses)
                    , guesses = model.guesses ++ [ model.currentGuess ]
                  }
                , Ports.sendDataOutside
                    (Ports.PersistData
                        { idx =
                            case List.findIndex ((==) model.answer) words of
                                Just i ->
                                    i

                                Nothing ->
                                    0
                        , guesses = model.guesses ++ [ model.currentGuess ]
                        , history = model.history
                        , winStreakCurrent = model.winStreakCurrent
                        , winStreakBest = model.winStreakBest
                        }
                    )
                )

        TypeLetter inputStr ->
            let
                inputC =
                    String.toList inputStr
            in
            ( { model
                | currentGuess =
                    if List.all Char.isAlpha inputC then
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
            List.member m.answer m.guesses

        attempts =
            List.map
                (\n ->
                    case List.getAt n m.guesses of
                        Just a ->
                            if a == m.answer then
                                (renderGuess << match m.answer) a

                            else
                                (renderGuess << match m.answer) a

                        Nothing ->
                            if n == List.length m.guesses && not found then
                                attempt { value = m.currentGuess, disabled = False }

                            else
                                Html.div [ Attrs.class "guess" ]
                                    (List.repeat 5 (Html.span [ Attrs.class "empty" ] [ Html.text "_" ]))
                )
            <|
                List.range 0 (maxGuesses - 1)
    in
    [ Html.div [ Attrs.class "wrapper" ]
        [ Html.text
            (if List.member m.answer m.guesses then
                "Success!! The answer is " ++ m.answer

             else if List.length m.guesses == maxGuesses then
                "Unsuccessful! The answer is " ++ m.answer

             else
                ""
            )
        , Html.div [ Attrs.class "guesses" ] attempts
        , viewTried m.currentGuess m.tried
        ]

    -- , details m
    ]


type alias InputState =
    { disabled : Bool
    , value : String
    }


attempt : InputState -> Html Msg
attempt s =
    Html.div [ Attrs.class "attempt" ]
        [ Html.input [ Attrs.maxlength 5, Attrs.value s.value, Attrs.disabled s.disabled, Attrs.onInput TypeLetter ] []
        , Html.button [ Attrs.disabled (s.disabled || String.length s.value < 5), Attrs.onClick SubmitGuess ] [ Html.text "Enter" ]
        ]


renderGuess : List (Ptn Char) -> Html Msg
renderGuess =
    Html.div [ Attrs.class "guess" ]
        << List.map
            (\ptn ->
                case ptn of
                    Exact c ->
                        Html.span [ Attrs.class "letter", Attrs.style "background-color" "green" ] [ Html.text (String.fromChar c) ]

                    Present c ->
                        Html.span [ Attrs.class "letter", Attrs.style "background-color" "orangered" ] [ Html.text (String.fromChar c) ]

                    Absent c ->
                        Html.span [ Attrs.class "letter" ] [ Html.text (String.fromChar c) ]
            )


viewTried : String -> List Tried -> Html Msg
viewTried currentGuess ws =
    Html.div [] <|
        List.map
            (\t ->
                case t of
                    Tried True c ->
                        Html.span [ Attrs.disabled True, Attrs.style "background-color" "lightgrey" ] [ Html.text (String.fromChar c) ]

                    Tried False c ->
                        Html.span [ Attrs.onClick (TypeLetter (currentGuess ++ String.fromChar c)) ] [ Html.text (String.fromChar c) ]
            )
            ws


details : Model -> Html Msg
details s =
    Html.div []
        [ Html.div [] [ Html.text ("guesses so far: " ++ (List.length s.guesses |> String.fromInt)) ]

        --  , Html.div [] [ Html.text ("ans: " ++ s.answer) ]
        , Html.div [] [ Html.text ("won: " ++ String.fromInt s.won) ]
        , Html.div [] [ Html.text ("played: " ++ (s.played |> String.fromInt)) ]
        , Html.div [] [ Html.text ("history: " ++ List.foldr ((++) << String.fromInt) "" s.history) ]
        ]
