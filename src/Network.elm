module Network exposing(..)

import Json.Decode exposing(Decoder, map2, map3, maybe, 
   field, string, float, list, decodeString)


type Node =
  Node String (Maybe String)

type Edge =
  Edge Node Node Float

type Network =
  Network (List Node) (List Edge)


--
-- NODES
--

createNode : String -> Node
createNode name_ =
  Node name_ Nothing

name : Node -> String
name (Node name_ _) =
  name_

equalNodes : Node -> Node -> Bool 
equalNodes node1 node2 =
  (name node1) == (name node2 )

--
-- EDGES
--

createEdge : Node -> Node -> Float -> Edge 
createEdge sourceNode sinkNode flow = 
  Edge sourceNode sinkNode flow 

edgeFlow : Edge -> Float
edgeFlow (Edge sourceNode sinkNode flow)  =
 flow 

initialNode : Edge -> Node 
initialNode (Edge initialNode_ terminalNode_ _) =
  initialNode_


terminalNode : Edge -> Node 
terminalNode (Edge initialNode_ terminalNode_ _) =
  terminalNode_ 

--
-- NETWORK
-- 

{-| buildNetwork consructs a value of type Network
    given a list of nodes and a list of edges
-}
buildNetwork : (List Node) -> (List Edge) -> Network
buildNetwork node_ edges_ = 
  Network node_ edges_ 


{-
  Network display functions
-}

listNodeNames : Network -> (List String)
listNodeNames (Network nodes edges) =
  List.map name nodes 

edgeName :  Edge -> String 
edgeName (Edge initialNode_ terminalNode_ flowRate) = 
  (name initialNode_)
  ++
  "->"
  ++
  (name terminalNode_)
  
edgeNameWithFlow : Edge -> String 
edgeNameWithFlow edge= 
    (edgeName edge) ++ ": " ++ (String.fromFloat (edgeFlow edge))

listEdgeNames : Network -> (List String)
listEdgeNames (Network nodes edges) =
  List.map edgeName edges

listEdgeNamesWithFlow : Network -> (List String)
listEdgeNamesWithFlow (Network nodes edges) =
  List.map edgeNameWithFlow edges


{-|

   Functions with Boolean values.s

-}
edgeHasOrigin : Node -> Edge -> Bool 
edgeHasOrigin node edge = 
  equalNodes node (initialNode edge)  

edgeHasTerminalNode: Node -> Edge -> Bool 
edgeHasTerminalNode node edge = 
  equalNodes node (terminalNode edge)  


{- Functions to compute flows. -}

outgoingEdges : Network -> Node -> (List Edge)
outgoingEdges (Network nodes edges) node = 
  List.filter  (edgeHasOrigin node) edges

incomingEdges : Network -> Node -> (List Edge)
incomingEdges (Network nodes edges) node = 
  List.filter  (edgeHasTerminalNode node) edges

outflowFromNode : Network -> Node -> Float 
outflowFromNode network node =
  (outgoingEdges network node ) 
    |> List.map edgeFlow
    |> List.sum
  
inflowToNode : Network -> Node -> Float 
inflowToNode network node =
  (incomingEdges network node ) 
    |> List.map edgeFlow
    |> List.sum

totalFlow : Network -> Float 
totalFlow (Network nodes edges) = 
  let
      network = Network nodes edges
  in
     List.map edgeFlow edges 
       |> List.sum 


{-  
  Functions for the model
 -}

efficiencyOfEdge : Float ->  Network -> Edge ->Float 
efficiencyOfEdge totalFlow_ network (Edge sourceNode sinkNode flow)  = 
   let
     edge = (Edge sourceNode sinkNode flow)
     edgeFlow_ = edgeFlow edge
     denominator = (outflowFromNode network sourceNode) * (inflowToNode network sinkNode)
     numerator = (edgeFlow_) * totalFlow_
     logRatio = (logBase 2)(numerator/denominator)
   in
     roundTo 3 (edgeFlow_ * logRatio)

resilienceOfEdge : Float ->  Network -> Edge ->Float 
resilienceOfEdge totalFlow_ network (Edge sourceNode sinkNode flow)  = 
   let
     edge = (Edge sourceNode sinkNode flow)
     edgeFlow_ = edgeFlow edge
     denominator = (outflowFromNode network sourceNode) * (inflowToNode network sinkNode)
     numerator = edgeFlow_* edgeFlow_
     logRatio = (logBase 2)(numerator/denominator)
   in
     edgeFlow_ * logRatio

efficiency : Network -> Float 
efficiency (Network nodes edges) =
  let   
    network = (Network nodes edges)
    totalFlow_ = totalFlow network 
  in 
    List.map (efficiencyOfEdge totalFlow_ network) edges  
      |> List.sum
      |> \x -> roundTo 3 x

resilience : Network -> Float 
resilience (Network nodes edges) =
  let   
    network = (Network nodes edges)
    totalFlow_ = totalFlow network 
  in 
    List.map (resilienceOfEdge totalFlow_ network) edges  
      |> List.sum
      |> \x -> -(roundTo 3 x)  

alpha : Network -> Float 
alpha network = 
  let 
    ratio = 1 + ((resilience net) / (efficiency net))
  in   
    1/ratio  

sustainability : Network -> Float 
sustainability network = 
  let   
    a = alpha network 
    aa = a^1.288
    s =  -1.844 * aa * (logBase 2 aa)
  in 
    roundTo 4 s

sustainabilityPercentage : Network -> Float  
sustainabilityPercentage network = 
  roundTo 2 (100 * (sustainability network))

{-

 Auxiliary functions

-}

roundTo : Int -> Float -> Float 
roundTo places quantity = 
  let   
    factor = 10^places
    ff = (toFloat factor)
    q2 = ff * quantity
    q3 = round q2
  in   
    (toFloat q3) / ff 
  


--
  -- NETWORK TEST DATA
--

u1 = createNode "U1"
u2 = createNode "U2"
u3 = createNode "U3"
u4 = createNode "U4"

e14 = createEdge u1 u4 30
e12 = createEdge u1 u2 90.4
e43 = createEdge u4 u3 22
e23 = createEdge u2 u3 31.4

net = buildNetwork [u1, u2, u3, u4] [e14, e12, e43, e23 ] 
    
---
--- JSON DECODERS
---

decodeNode : Decoder Node
decodeNode =
  map2 Node
    (field "name" string)
    (maybe (field "imageHash" string))

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


---
--- Json.Decode Tests
---

nodeA = """
  {"name": "A",
    "imageHash": ""
  }
"""

nodeB = """
  {"name": "B",
    "imageHash": ""
  }
"""

edgeAB = """
  {
     "initialNode": {"name": "A", "imageHash": "" }, 
     "terminalNode": {"name": "B", "imageHash": "" },
     "flow": 17.3
  }
"""

netAsJson1 = """
  { 
    "nodes": [
      {"name": "A", "imageHash": "" }, 
      {"name": "A", "imageHash": "" }
    ], 
    "edges": [
        {
          "initialNode": {"name": "A", "imageHash": "" }, 
          "terminalNode": {"name": "B", "imageHash": "" },
          "flow": 17.3
        }
    ]

  }
"""

{-

TESTS:

> decodeString decodeNode nodeA
Ok (Node "A" (Just ""))

> decodeString decodeNode nodeB
Ok (Node "B" (Just ""))

> decodeString decodeEdge edgeAB
Ok (Edge (Node "A" (Just "")) (Node "B" (Just "")) 17.3)
    : Result Error Edge

> decodeString decodeNetwork netAsJson1
Ok (Network [Node "A" (Just ""),Node "A" (Just "")] [Edge (Node "A" (Just "")) (Node "B" (Just "")) 17.3])


-}


{- 
   A FURTHER TEST
   --------------

   The `testNetwork` function takes input a JSON string representation
   of a network.  It converts that representation into an actual
   Network value, then computes the sustainabilityPercentage for 
   that network.  The sustainabilityPercentage exercises all 
   significant parts of the Network module.

-}

sustainabilityPercentageOfNetworkAsJSON : String -> Float 
sustainabilityPercentageOfNetworkAsJSON jsonString = 
  case decodeString decodeNetwork jsonString of   
     Ok network -> sustainabilityPercentage network
     Err _ -> -1.0

{-

  Resuls of the test
  ------------------

  > sustainabilityPercentageOfNetworkAsJSON netAsJson2
  96.99 : Float

-}


netAsJson2 = """
  {
    "nodes": [
      {"name": "U1", "imageHash": "" }, 
      {"name": "U2", "imageHash": "" },
      {"name": "U3", "imageHash": "" }, 
      {"name": "U2", "imageHash": "" }
    ], 
    "edges": [
        {
          "initialNode": {"name": "U1", "imageHash": "" }, 
          "terminalNode": {"name": "U4", "imageHash": "" },
          "flow": 30
        },
        {
          "initialNode": {"name": "U1", "imageHash": "" }, 
          "terminalNode": {"name": "U2", "imageHash": "" },
          "flow": 90.4
        },
        {
          "initialNode": {"name": "U4 ", "imageHash": "" }, 
          "terminalNode": {"name": "U3", "imageHash": "" },
          "flow": 22
        },
        {
          "initialNode": {"name": "U2", "imageHash": "" }, 
          "terminalNode": {"name": "U3", "imageHash": "" },
          "flow": 31.4
        }
    ]
  }

"""



