module Types exposing (Model, Msg(..), Ptn(..), Tried(..))

type Msg
    = SubmitGuess
    | TypeLetter String


type alias Model =
    { answer : String
    , currentGuess : String
    , guesses : List String
    , tried : List Tried

    -- history detail pt games finished on each guess
    , history : List Int
    , played : Int
    , won : Int
    , winStreakCurrent : Int
    , winStreakBest : Int
    }


type Ptn a
    = Exact a
    | Present a
    | Absent a


type Tried
    = Tried Bool Char
