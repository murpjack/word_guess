port module Ports exposing (DataForJs(..), sendDataOutside)

import Json.Encode as Encode


type alias DataToPersist =
    { idx : Int
    , guesses : List String
    , history : List Int
    , winStreakCurrent : Int
    , winStreakBest : Int
    }


type DataForJs
    = PersistData DataToPersist


type alias GenericPortData =
    { tag : String, data : Encode.Value }


sendDataOutside : DataForJs -> Cmd msg
sendDataOutside data =
    case data of
        PersistData d ->
            outgoingData
                { tag = "PersistData"
                , data =
                    Encode.object
                        [ ( "idx", Encode.int d.idx )
                        , ( "guesses", Encode.list Encode.string d.guesses )
                        , ( "history", Encode.list Encode.int d.history )
                        , ( "winStreakCurrent", Encode.int d.winStreakCurrent )
                        , ( "winStreakBest", Encode.int d.winStreakBest )
                        ]
                }


port outgoingData : GenericPortData -> Cmd msg


port incomingData : (GenericPortData -> msg) -> Sub msg
