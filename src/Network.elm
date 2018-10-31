module Network exposing(..)

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

buildNetwork : (List Node) -> (List Edge) -> Network
buildNetwork node_ edges_ = 
  Network node_ edges_ 

listNodeNames : Network -> (List String)
listNodeNames (Network nodes edges) =
  List.map name nodes 


edgeHasOrigin : Node -> Edge -> Bool 
edgeHasOrigin node edge = 
  equalNodes node (initialNode edge)  

edgeHasTerminalNode: Node -> Edge -> Bool 
edgeHasTerminalNode node edge = 
  equalNodes node (terminalNode edge)  


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


efficiencyOfEdge : Float ->  Network -> Edge ->Float 
efficiencyOfEdge totalFlow_ network (Edge sourceNode sinkNode flow)  = 
   let
     edge = (Edge sourceNode sinkNode flow)
     edgeFlow_ = edgeFlow edge
     denominator = (outflowFromNode network sourceNode) * (inflowToNode network sinkNode)
     numerator = (edgeFlow_) * totalFlow_
     logRatio = (logBase 2)(numerator/denominator)
   in
     edgeFlow_ * logRatio

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

resilience : Network -> Float 
resilience (Network nodes edges) =
  let   
    network = (Network nodes edges)
    totalFlow_ = totalFlow network 
  in 
    List.map (resilienceOfEdge totalFlow_ network) edges  
      |> List.sum
      |> \x -> -x   

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
  roundTo 2 (sustainability network)

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
-- TEST DATA
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
    