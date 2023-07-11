module Types exposing (Model, Msg(..), Ptn(..))


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
