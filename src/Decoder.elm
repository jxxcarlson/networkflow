module Decoder exposing(..)

import Network exposing(Node(..), Edge(..), Network(..), SimpleEdge(..), 
  edgeListFromSimpleEdgeList, sustainabilityPercentage)

import Json.Decode exposing(Decoder, map, map2, map3, maybe, 
   field, string, float, list, decodeString)



getEdgesFromJson : String -> (List Edge)
getEdgesFromJson jsonString =
  case decodeString decodeSimpleEdgeList jsonString of  
    Err _ -> [] 
    Ok simpleEdgeList -> edgeListFromSimpleEdgeList simpleEdgeList


sustainabilityPercentageOfNetworkAsJSON : String -> Float 
sustainabilityPercentageOfNetworkAsJSON jsonString = 
  case decodeString decodeNetwork jsonString of   
     Ok network -> sustainabilityPercentage network
     Err _ -> -1.0
   
---
--- JSON DECODERS
---

decodeNode : Decoder Node
decodeNode =
  map Node
    (field "name" string)

decodeEdge : Decoder Edge
decodeEdge =
  map3 Edge
    (field "initialNode" decodeNode)
    (field "terminalNode" decodeNode)
    (field "flow" float)

decodeNetwork : Decoder Network 
decodeNetwork =
  map2 Network
    (field "nodes" (list decodeNode))
    (field "edges" (list decodeEdge))


decodeSimpleEdge : Decoder SimpleEdge 
decodeSimpleEdge =
  map3 SimpleEdge 
     (field "initialNode" string)
     (field "terminalNode" string)
     (field "flow" float)

decodeSimpleEdgeList : Decoder (List SimpleEdge)
decodeSimpleEdgeList = 
  (field "edges" (list decodeSimpleEdge))

