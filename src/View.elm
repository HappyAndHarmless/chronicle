module View where

import String exposing (toLower)
import Signal exposing (Address)
import Markdown

import Model
import Controller
import Html exposing (..)
import Html.Attributes exposing (..)


viewFeelingGroup : Model.DayFeelings -> Html
viewFeelingGroup (day, feelings) =
  div []
  [ h2 [] [text day],
    ul [] (List.map viewFeeling feelings) ]


viewFeeling : Model.Feeling -> Html
viewFeeling feeling =
  li []
     [
       strong [] [ text feeling.at ],
       text " | ",
       span [] [ viewFeelingHowOrWhat feeling.how feeling.what ],
       viewFeelingTrigger feeling.trigger,
       Markdown.toHtml feeling.notes
     ]

viewFeelingHowOrWhat : Model.How -> String -> Html
viewFeelingHowOrWhat how what =
  let
    howString    = toLower <| toString how
    elementStyle = style [ ("color", colorForHow how ) ]
    content      = if what == "" then howString else what
  in
    span [ elementStyle ] [text content]

viewFeelingTrigger : String -> Html
viewFeelingTrigger trigger =
  if | trigger == "" -> text ""
     | otherwise     -> span [] [ text " ( <- "
                                , strong [] [ text trigger ]
                                , text " ) " ]

colorForHow : Model.How -> String
colorForHow how =
  case how of
    Model.Great -> "green"
    Model.Good  -> "blue"
    Model.Meh   -> "grey"
    Model.Bad   -> "orange"
    Model.Terrible -> "red"


view : Address Controller.Action -> Model.Model -> Html
view address feelings =
  let
    feelingGroups = Model.groupFeelings feelings
  in
    div []
    [ h1 [] [ text "Feelings" ],
      div [] (List.map viewFeelingGroup feelingGroups) ]