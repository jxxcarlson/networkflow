module Decoder exposing(..)

import Network exposing(Node(..), Edge(..), Network(..), SimpleEdge(..), 
  edgeListFromSimpleEdgeList, emptyNetwork)

import Flow exposing(sustainabilityPercentage)

import Json.Decode exposing(Decoder, map, map2, map3, maybe, 
   field, string, float, list, decodeString)


---
--- BUILD
---


networkFromJson : String -> Network 
networkFromJson jsonString = 
  case decodeString decodeNetwork jsonString of 
     Err _ -> emptyNetwork 
     Ok network -> network


edgesFromJson : String -> (List Edge)
edgesFromJson jsonString =
  case decodeString decodeSimpleEdgeList jsonString of  
    Err _ -> [] 
    Ok simpleEdgeList -> edgeListFromSimpleEdgeList simpleEdgeList

---
--- JSON DECODERS
---


decodeNetwork : Decoder Network 
decodeNetwork = 
  map2 Network
    (field "nodes" (list decodeNode))
    (field "edges" (map edgeListFromSimpleEdgeList (list decodeSimpleEdge)))

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

---
--- SIMPLE EDGES
---

decodeSimpleEdge : Decoder SimpleEdge 
decodeSimpleEdge =
  map3 SimpleEdge 
     (field "initialNode" string)
     (field "terminalNode" string)
     (field "flow" float)

decodeSimpleEdgeList : Decoder (List SimpleEdge)
decodeSimpleEdgeList = 
  (field "edges" (list decodeSimpleEdge))

