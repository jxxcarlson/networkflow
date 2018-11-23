module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Attributes
import Network
    exposing
        ( Network(..)
        , emptyNetwork
        )
import NetworkParser exposing (networkFromString)
import Widget
import Svg exposing (svg)
import Display
import FlowModel
    exposing
        ( exampleNetwork
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


type Msg
    = NoOp
    | InputNetworkString String
    | InputSourceNode String
    | InputTargetNode String
    | InputEdgeFlow String
    | UpdateNetwork


type alias Model =
    { message : String
    , networkAsString : String
    , network : Network
    , sourceNode : String
    , targetNode : String
    , edgeFlow : String
    }


initialNetworkString =
    """U1, U4, 30; U1, U2, 90.4; U4, U3, 22; U2, U3, 31.4;
V1, V4, 30; V1, V2, 90.4; V4, V3, 22; V2, V3, 31.4;
U1, V1, 30;
"""


initialModel : Model
initialModel =
    { message = "Hello!"
    , networkAsString = initialNetworkString
    , network = networkFromString initialNetworkString
    , sourceNode = ""
    , targetNode = ""
    , edgeFlow = ""
    }


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel, Cmd.none )


subscriptions model =
    Sub.batch
        []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        InputNetworkString str ->
            ( { model | networkAsString = str }, Cmd.none )

        UpdateNetwork ->
            let
                newEdgeFlow =
                    String.toFloat model.edgeFlow |> Maybe.withDefault 0

                newNetworkAsString =
                    if model.sourceNode /= "" && model.targetNode /= "" && newEdgeFlow > 0 then
                        model.networkAsString
                            |> NetworkParser.simpleEdgeListFromString
                            |> Network.replaceSimpleEdge model.sourceNode model.targetNode newEdgeFlow
                            |> NetworkParser.stringOfSimpleEdgeList
                    else if model.sourceNode /= "" && model.targetNode /= "" && newEdgeFlow == 0 then
                        model.networkAsString
                            |> NetworkParser.simpleEdgeListFromString
                            |> Network.deleteSimpleEdge model.sourceNode model.targetNode
                            |> NetworkParser.stringOfSimpleEdgeList
                    else
                        model.networkAsString

                newNetwork =
                    networkFromString newNetworkAsString
                        |> Network.changeNodeInfoInNetwork "AA" "https://s3.amazonaws.com/noteimages/jxxcarlson/hello.jpg"

                -- changeNodeInfoInList nodeName nodeInfo nodeList
            in
                ( { model
                    | networkAsString = newNetworkAsString
                    , network = newNetwork
                  }
                , Cmd.none
                )

        InputSourceNode str ->
            ( { model | sourceNode = str }, Cmd.none )

        InputTargetNode str ->
            ( { model | targetNode = str }, Cmd.none )

        InputEdgeFlow str ->
            ( { model | edgeFlow = str }, Cmd.none )


view : Model -> Html Msg
view model =
    layout [] (mainRow model)


mainRow : Model -> Element Msg
mainRow model =
    column [ width fill, centerX, centerY, spacing 40, Font.size 16 ]
        [ el [ Font.bold, Font.size 24, centerX ] (text "Network")
        , row [ centerX, spacing 60 ] (networkDisplay model)
        , row [ centerX ] [ networkEntryForm model ]
        , row [ centerX ] [ networkInput model ]
        , row [ centerX ] [ updateNetworkButton model ]
        ]


networkDisplay : Model -> List (Element Msg)
networkDisplay model =
    [ column [ centerX, alignTop ] [ displayNetwork model ]
    , column dataColumnStyle (displayListWithTitle "Nodes" <| displayNodes model.network)
    , column dataColumnStyle (displayListWithTitle "Edges" <| displayEdges model.network)
    , column [ centerX, alignTop ] [ report model.network ]
    ]


dataColumnStyle =
    [ centerX, spacing 10, alignTop, scrollbarX, height (px 300) ]


networkInput : Model -> Element Msg
networkInput model =
    Input.multiline [ width (px 600), height (px 120) ]
        { onChange = InputNetworkString
        , text = model.networkAsString
        , placeholder = Nothing
        , label = Input.labelAbove [ Font.size 18, Font.bold ] (text "Network data")
        , spellcheck = False
        }


updateNetworkButton : Model -> Element Msg
updateNetworkButton model =
    Input.button Widget.buttonStyle
        { onPress = Just UpdateNetwork
        , label = Element.text "Update Network"
        }


displayNetwork : Model -> Element msg
displayNetwork model =
    Element.html
        (svg [ Html.Attributes.width 400, Html.Attributes.height 400 ]
            (Display.networkDisplay 200 model.network)
        )


networkEntryForm : Model -> Element Msg
networkEntryForm model =
    row [ spacing 8 ]
        [ inputSourceNode model, inputTargetNode model, inputEdgeFlow model ]


inputSourceNode model =
    Input.text [ height (px 25), width (px 100) ]
        { onChange = InputSourceNode
        , text = model.sourceNode
        , placeholder = Nothing
        , label = Input.labelAbove [ Font.size 14, Font.bold ] (text "Source node")
        }


inputTargetNode model =
    Input.text [ height (px 25), width (px 100) ]
        { onChange = InputTargetNode
        , text = model.targetNode
        , placeholder = Nothing
        , label = Input.labelAbove [ Font.size 14, Font.bold ] (text "Target node")
        }


inputEdgeFlow model =
    Input.text [ height (px 25), width (px 100) ]
        { onChange = InputEdgeFlow
        , text = model.edgeFlow
        , placeholder = Nothing
        , label = Input.labelAbove [ Font.size 14, Font.bold ] (text "Flow")
        }
