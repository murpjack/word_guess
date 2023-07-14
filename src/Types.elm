module Types exposing (Model, Msg(..), Ptn(..), Tried(..))


type Msg
    = SubmitGuess
    | TypeLetter String


type alias Model =
    { currentGuess : String
    , answer : Maybe String
    , guesses : List String
    , tried : List Tried
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


type Tried
    = Tried Bool Char
