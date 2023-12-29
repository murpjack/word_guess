module Flags exposing (Flags, decode, default)

import Json.Decode as Decode exposing (Decoder)


type alias Flags =
    { idx : Int
    , guesses : List String
    , history : List Int
    , winStreakCurrent : Int
    , winStreakBest : Int
    }



-- FIXME: These defaults aren't meangingful


default : Flags
default =
    { idx = 0 -- This is a meaningless default
    , guesses = []
    , history = []
    , winStreakCurrent = 0
    , winStreakBest = 0
    }


decode : Decoder Flags
decode =
    Decode.map5 Flags
        (Decode.field "idx" Decode.int)
        (Decode.field "guesses" (Decode.list Decode.string))
        (Decode.field "history" (Decode.list Decode.int))
        (Decode.field "winStreakCurrent" Decode.int)
        (Decode.field "winStreakBest" Decode.int)
