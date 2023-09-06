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


{-| This Ptn type describes whether a subpattern, Char, found in a pattern, String,
is an exact match, or whether it exists, or whether it does not exist at all.
-}
type Ptn a
    = Exact a
    | Present a
    | Absent a


type Tried
    = Tried Bool Char
