module Decoder2 exposing(networkFromJson)

import Network exposing(Node(..), Edge(..), Network(..), SimpleEdge(..), 
  sourceNameOfSimpleEdge, sinkNameOfSimpleEdge, createNode
  , edgeListFromSimpleEdgeList, emptyNetwork)

import Flow exposing(sustainabilityPercentage)

import Json.Decode exposing(Decoder, map, map2, map3, maybe, 
   field, string, float, list, decodeString)
   
import Tools exposing(unique)

import ParserTools

---
--- BUILD
---

networkFromJson : String -> Network   
networkFromJson     str =
  Network (nodesFromJson str) (edgesFromJson str)



simpleEdgeListFromJson : String -> List (SimpleEdge) 
simpleEdgeListFromJson jsonString = 
  case decodeString decodeSimpleEdgeList jsonString of 
     Err _ -> []
     Ok edgeList -> edgeList


nodesFromJson : String -> (List Node)
nodesFromJson str = 
  nodeNamesFromJson str |> List.map createNode

nodeNamesFromJson : String -> (List String)
nodeNamesFromJson str  =
  let 
    simpleEdgeList = simpleEdgesFromJson str
    sourceNodeNames = simpleEdgeList |> List.map sourceNameOfSimpleEdge
    sinkNodeNames = simpleEdgeList |> List.map sinkNameOfSimpleEdge
  in   
    sourceNodeNames ++ sinkNodeNames |> unique |> List.sort



simpleEdgesFromJson : String -> (List SimpleEdge)
simpleEdgesFromJson jsonString =
  case decodeString decodeEdgesFromData jsonString of  
    Err _ -> [] 
    Ok simpleEdgeList -> simpleEdgeList


edgesFromJson : String -> (List Edge)
edgesFromJson jsonString =
  case decodeString decodeEdgesFromData jsonString of  
    Err _ -> [] 
    Ok simpleEdgeList -> edgeListFromSimpleEdgeList simpleEdgeList

---
--- JSON DECODERS
---


decodeNetwork : Decoder Network 
decodeNetwork = 
  (field "data" decodeNetworkAux)

decodeNetworkAux : Decoder Network 
decodeNetworkAux = 
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
    (field "from" decodeNode)
    (field "to" decodeNode)
    (field "amount" float)

---
--- SIMPLE EDGES
---

jsss = """{"value":"1 BES","to":"james1111111","symbol":"BES","memo":"","from":"lucca1111111","block_time":"2018-11-03T18:48:52.500"}"""




decodeEdgesFromData : Decoder (List SimpleEdge)
decodeEdgesFromData = 
  field "data" decodeSimpleEdgeList


decodeSimpleEdgeList : Decoder (List SimpleEdge)
decodeSimpleEdgeList = 
  list decodeSimpleEdge



decodeSimpleEdge : Decoder SimpleEdge 
decodeSimpleEdge =
  map3 SimpleEdge 
     (field "from" string)
     (field "to" string)
     (field "value" string |> map ParserTools.flowRateFromString)





jsonXX = """
{"value":"1 BES","to":"james1111111","symbol":"BES","memo":"","from":"lucca1111111","block_time":"2018-11-03T18:48:52.500"}
"""
 