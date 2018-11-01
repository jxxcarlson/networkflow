module Main exposing(main)

import Browser
import Element exposing(..)
import Element.Font as Font
import Html exposing(Html)
import Network exposing(
     Network(..)
     , emptyNetwork 
    )
import FlowModel exposing(
    exampleNetwork
    , displayListWithTitle
    , displayNodes
    , displayEdges
    , report
  )


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type Msg = 
  NoOp

type alias Model = { 
    message: String
    , network : Network }

initialModel : Model  
initialModel = 
  { message = "Hello!"
  , network = emptyNetwork
 }

type alias Flags =
    {}

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none)


subscriptions model =
    Sub.batch
        [  ]

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none ) 

view : Model -> Html msg
view model = 
  layout [] (mainRow model)

mainRow : Model -> Element msg
mainRow model =
  column [width fill, centerX, centerY, spacing 40, Font.size 16 ] [
    el [Font.bold, Font.size 24, centerX] (text "Network")
    , row [centerX, spacing 60 ] (networkDisplay model)
  ]
 
      

networkDisplay : model -> List (Element msg)
networkDisplay model = 
     [
           column dataColumnStyle (displayListWithTitle "Nodes" <| displayNodes exampleNetwork)
         , column dataColumnStyle (displayListWithTitle "Edges" <| displayEdges exampleNetwork)
         , column [centerX, alignTop ] [report exampleNetwork]
     ]

dataColumnStyle = [centerX, spacing 10, alignTop, scrollbarX, height (px 300)]