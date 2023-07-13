module Flags exposing (Flags, decode, default)

import Json.Decode as Decode exposing (Decoder)


type alias Flags =
    { random : Maybe Int
    }


default : Flags
default =
    { random = Nothing
    }


decode : Decoder Flags
decode =
    Decode.map Flags
        (Decode.field "random" (Decode.maybe Decode.int))
