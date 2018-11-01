module FlowModel exposing(
    displayNodes
  , displayEdges
  , displayListWithTitle
  , report
  , exampleNetwork
  )

import Element exposing(Element, text, px, el, alignRight)
import Element.Font as Font

import Network exposing(
    Network(..)
    , listNodes
    , listEdgesWithFlow
    , nodeCount
    , edgeCount
   )
import Flow exposing(
    efficiency
    , resilience
    , sustainabilityPercentage
    , roundTo
    )



import Example

type alias Item = 
  { 
      label: String,
      value: String
  }

summarize : Network -> List Item
summarize network = 
  [
       { label = "Nodes", value = String.fromInt <| nodeCount network }
      , { label = "Edges", value = String.fromInt <| edgeCount network } 
      ,  { label = "Efficiency", value = String.fromFloat <| (roundTo 1) <| efficiency network }
      , { label = "Resilience", value = String.fromFloat <| (roundTo 1) <| resilience network }
      , { label = "Sustainability", value = String.fromFloat <| (roundTo 1) <| sustainabilityPercentage network }


  ]
  
report : Network -> Element msg
report network = 
    Element.table [Element.spacing 10, Element.width (px 240) ]
        { data = summarize network
        , columns =
            [ { header = el [Font.bold] (Element.text "Measure")
            , width = Element.fill
            , view =
                    \datum ->
                        Element.text datum.label
            }
            , { header = el [Font.bold] (Element.text "Value")
            , width = Element.fill
            , view =
                    \datum ->
                        Element.el [alignRight] (Element.text datum.value)
            }
            ]
        }
    

displayListWithTitle : String -> List(Element msg) -> List(Element msg)
displayListWithTitle title list = 
  [Element.el [Font.bold] (text title)] ++ list

displayNodes : Network -> List(Element msg)
displayNodes network = 
  listNodes network 
    |> List.map (\node -> Element.row [] [text node])

displayEdges : Network -> List(Element msg)
displayEdges network = 
  listEdgesWithFlow network 
    |> List.map (\edge -> Element.row [] [text edge])

exampleNetwork : Network
exampleNetwork = Example.net

