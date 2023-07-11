module Main exposing (..)

import Browser
import Debug exposing (toString)
import Html exposing (Html)
import Html.Attributes as Attrs
import Html.Events as Attrs
import Json.Decode as Decode
import List.Extra as List
import Triple


words : List String
words =
    [ "water" ]


answer : String
answer =
    "water"


type Msg
    = SubmitGuess
    | TypeLetter String


type alias Model =
    { currentGuess : String
    , guesses : List String
    , played : List String
    , won : Int
    , message : String

    -- history detail pt games finished on each guess
    , history : List Int
    , winStreakCurrent : Int
    , winStreakBest : Int
    }


type Ptn a
    = Exact a
    | Present a
    | Absent a


match : String -> List (Ptn Char)
match guess =
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


renderGuess : List (Ptn a) -> List (Html Msg)
renderGuess =
    List.map
        (\ptn ->
            case ptn of
                Exact c ->
                    Html.span [ Attrs.style "color" "green" ] [ Html.text (toString c) ]

                Present c ->
                    Html.span [ Attrs.style "color" "orangered" ] [ Html.text (toString c) ]

                Absent c ->
                    Html.span [] [ Html.text (toString c) ]
        )


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
                    if model.currentGuess /= w && List.length model.guesses == maxGuesses - 1 then
                        ( { model
                            | message = "too bad. try again tomorrow"
                            , guesses = model.currentGuess :: model.guesses
                            , played = w :: model.played
                            , winStreakCurrent = 0
                          }
                        , Cmd.none
                        )

                    else if model.currentGuess == w then
                        ( { model
                            | message = "yay"
                            , guesses = model.currentGuess :: model.guesses
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
                            , guesses = model.currentGuess :: model.guesses
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
    , body =
        [ Html.div [ Attrs.id "app" ]
            [ Html.text (toString model)
            , Html.div [] (List.map previousGuess model.guesses)
            , game
                { value = model.currentGuess
                , disabled = List.length model.guesses >= maxGuesses
                }
            , details model
            , Html.text model.message
            ]
        ]
    }


previousGuess : String -> Html Msg
previousGuess guess =
    Html.div []
        (match guess
            |> renderGuess
        )


type alias InputState =
    { disabled : Bool
    , value : String
    }


game : InputState -> Html Msg
game s =
    Html.div []
        [ Html.input [ Attrs.value s.value, Attrs.disabled s.disabled, Attrs.onInput TypeLetter ] []
        , Html.button [ Attrs.onClick SubmitGuess ] [ Html.text "Enter" ]
        ]


details : Model -> Html Msg
details s =
    Html.div []
        [ Html.div [] [ Html.text ("guesses so far: " ++ (List.length s.guesses |> toString)) ]
        , Html.div [] [ Html.text ("won: " ++ toString s.won) ]
        , Html.div [] [ Html.text ("played: " ++ (List.length s.played |> toString)) ]
        , Html.div [] [ Html.text ("history: " ++ toString s.history) ]
        ]
