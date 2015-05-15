module Model where

import List
import String
import Json.Decode  as J
import Json.Decode exposing ((:=))

import Util exposing (groupBy)
import Util as U

type alias Model =
  { feelings : List Feeling
  , keywords : String
  }

type alias Feeling =
  { how     : How
  , what    : String
  , trigger : String
  , notes   : String
  , at      : String  -- XXX: must fix date time type
  , day     : String
  }

type How = Great | Good | Meh | Bad | Terrible

-- JSON decoders

decodeHow : J.Decoder How
decodeHow =
  let f s = case s of
    "great"  -> Ok Great
    "good"  -> Ok Good
    "meh"  -> Ok Meh
    "bad"  -> Ok Bad
    "terrible"  -> Ok Terrible
    otherwise -> Err "Invalid `how` field"
  in
    J.customDecoder J.string f

decodeFeeling : J.Decoder Feeling
decodeFeeling = Feeling
  `J.map`    ("how"    := decodeHow)
  `U.andMap` ("what" := J.string)
  `U.andMap` ("trigger"  := J.string)
  `U.andMap` ("notes"   := J.string)
  `U.andMap` ("at"  := J.string)
  `U.andMap` ("day"  := J.string)

decodeModel : J.Decoder (List Feeling)
decodeModel = J.list decodeFeeling

initialModel : Model
initialModel = { feelings=[], keywords="" }


-- Grouping type

type alias DayFeelings = (String, (List Feeling))

groupFeelings : (List Feeling) -> (List DayFeelings)
groupFeelings =
  groupBy .day


-- Search

search : String -> List Feeling -> List Feeling
search keywords =
  List.filter (\feeling -> String.contains keywords <| String.toLower <| toString feeling.how)
