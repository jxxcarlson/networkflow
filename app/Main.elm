module Main exposing(main)

import Browser
import Element exposing(..)
import Element.Font as Font
import Element.Input as Input
import Html exposing(Html)
import Network exposing(
     Network(..)
     , emptyNetwork 
    )
import NetworkParser exposing(networkFromString)
import Widget

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
  | InputNetworkString String
  | UpdateNetwork 

type alias Model = { 
    message: String
    , networkAsString : String
    , network : Network }

initialModel : Model  
initialModel = 
  { message = "Hello!"
  , networkAsString =  "U1, U4, 30; U1, U2, 90.4; U4, U3, 22; U2, U3, 31.4;"
  , network =  networkFromString "U1, U4, 30; U1, U2, 90.4; U4, U3, 22; U2, U3, 31.4;"

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
        InputNetworkString str ->
            ({model | networkAsString = str }, Cmd.none)
        UpdateNetwork ->
          ({model | network =  networkFromString model.networkAsString}, Cmd.none )


view : Model -> Html Msg
view model = 
  layout [] (mainRow model)

mainRow : Model -> Element Msg
mainRow model =
  column [width fill, centerX, centerY, spacing 40, Font.size 16 ] [
    el [Font.bold, Font.size 24, centerX] (text "Network")
    , row [centerX, spacing 60 ] (networkDisplay model)
    , row [centerX] [networkInput model]
    , row [centerX] [updateNetworkButton model]
  ]
 
      

networkDisplay : Model -> List (Element msg)
networkDisplay model = 
     [
           column dataColumnStyle (displayListWithTitle "Nodes" <| displayNodes model.network)
         , column dataColumnStyle (displayListWithTitle "Edges" <| displayEdges model.network)
         , column [centerX, alignTop ] [report model.network]
     ]

dataColumnStyle = [centerX, spacing 10, alignTop, scrollbarX, height (px 300)]


networkInput : Model -> Element Msg 
networkInput model = 
    Input.multiline [width (px 600), height (px 120) ]
      {
        onChange = InputNetworkString
      , text = model.networkAsString 
      , placeholder = Nothing
      , label =   Input.labelAbove [ Font.size 18, Font.bold ] (text "Network data")
      , spellcheck = False

      }

updateNetworkButton : Model -> Element Msg    
updateNetworkButton model = 
  Input.button Widget.buttonStyle {
    onPress =  Just UpdateNetwork
  , label = Element.text "Update Network"
  } 