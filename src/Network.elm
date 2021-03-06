module Network exposing (..)


type Node
    = Node String String


type Edge
    = Edge Node Node Float


type SimpleEdge
    = SimpleEdge String String Float


type Network
    = Network (List Node) (List Edge)


emptyNetwork : Network
emptyNetwork =
    Network [] []



--
-- NODES
--


createNode : String -> String -> Node
createNode name_ info_ =
    Node name_ info_


name : Node -> String
name (Node name_ info_) =
    name_


info : Node -> String
info (Node name_ info_) =
    info_


equalNodes : Node -> Node -> Bool
equalNodes node1 node2 =
    (name node1) == (name node2)


nodeHasName : String -> Node -> Bool
nodeHasName name_ (Node nodeName _) =
    name_ == nodeName


findNode : String -> Network -> Maybe Node
findNode name_ (Network nodes edges) =
    List.filter (nodeHasName name_) nodes
        |> List.head


findNodeInNodeList : String -> List Node -> Maybe Node
findNodeInNodeList name_ nodeList =
    List.filter (nodeHasName name_) nodeList
        |> List.head


nodeCount : Network -> Int
nodeCount (Network nodes edges) =
    List.length nodes


changeNodeInfo : String -> String -> Node -> Node
changeNodeInfo nodeName nodeInfo (Node name_ info_) =
    case name_ == nodeName of
        True ->
            (Node name_ nodeInfo)

        False ->
            (Node name_ info_)


changeNodeInfoInList : String -> String -> List Node -> List Node
changeNodeInfoInList nodeName nodeInfo nodeList =
    nodeList
        |> List.map (changeNodeInfo nodeName nodeInfo)


changeNodeInfoInNetwork : String -> String -> Network -> Network
changeNodeInfoInNetwork nodeName nodeInfo (Network nodeList edgeList) =
    (Network (changeNodeInfoInList nodeName nodeInfo nodeList) edgeList)



--
-- EDGES
--


createEdge : Node -> Node -> Float -> Edge
createEdge sourceNode sinkNode flow =
    Edge sourceNode sinkNode flow


edgeFlow : Edge -> Float
edgeFlow (Edge sourceNode sinkNode flow) =
    flow


initialNode : Edge -> Node
initialNode (Edge initialNode_ terminalNode_ _) =
    initialNode_


terminalNode : Edge -> Node
terminalNode (Edge initialNode_ terminalNode_ _) =
    terminalNode_


edgeCount : Network -> Int
edgeCount (Network nodes edges) =
    List.length edges


edgeMatches : String -> String -> Edge -> Bool
edgeMatches name1 name2 (Edge node1 node2 _) =
    name1 == (name node1) && name2 == (name node2)


edgeDoesNotMatch : String -> String -> Edge -> Bool
edgeDoesNotMatch name1 name2 (Edge node1 node2 _) =
    name1 /= (name node1) || name2 /= (name node2)


getEdge : String -> String -> Network -> Maybe Edge
getEdge sourceName sinkName (Network nodes edges) =
    List.filter (edgeMatches sourceName sinkName) edges
        |> List.head



--
-- SIMPLE EDGES
--


edgeListFromSimpleEdgeList : List SimpleEdge -> List Edge
edgeListFromSimpleEdgeList simpleEdgeList_ =
    List.map simpleEdgeToEdge simpleEdgeList_


simpleEdgeToEdge : SimpleEdge -> Edge
simpleEdgeToEdge (SimpleEdge sourceName_ sinkName flow) =
    Edge (createNode sourceName_ "") (createNode sinkName "") flow


sourceNameOfSimpleEdge : SimpleEdge -> String
sourceNameOfSimpleEdge (SimpleEdge sourceName sinkName _) =
    sourceName


sinkNameOfSimpleEdge : SimpleEdge -> String
sinkNameOfSimpleEdge (SimpleEdge sourceName sinkName _) =
    sinkName


stringOfSimpleEdge : SimpleEdge -> String
stringOfSimpleEdge (SimpleEdge sourceNode targetNode flow) =
    sourceNode ++ ", " ++ targetNode ++ ", " ++ String.fromFloat flow ++ ";"


deleteSimpleEdge : String -> String -> List SimpleEdge -> List SimpleEdge
deleteSimpleEdge sourceNode targetNode edgeList =
    List.filter (simpleEdgeDoesNotMatch sourceNode targetNode) edgeList


addSimpleEdge : String -> String -> Float -> List SimpleEdge -> List SimpleEdge
addSimpleEdge sourceNode targetNode flow edgeList =
    (SimpleEdge sourceNode targetNode flow) :: edgeList


replaceSimpleEdge : String -> String -> Float -> List SimpleEdge -> List SimpleEdge
replaceSimpleEdge sourceNode targetNode flow edgeList =
    edgeList
        |> deleteSimpleEdge sourceNode targetNode
        |> addSimpleEdge sourceNode targetNode flow


simpleEdgeDoesNotMatch : String -> String -> SimpleEdge -> Bool
simpleEdgeDoesNotMatch name1 name2 (SimpleEdge node1 node2 _) =
    name1 /= node1 || name2 /= node2



--
-- NETWORK
--
{- Build, Edit Network -}


buildNetwork : List Node -> List Edge -> Network
buildNetwork node_ edges_ =
    Network node_ edges_


insertEdge : String -> String -> Float -> Network -> Network
insertEdge name1 name2 flow network =
    let
        maybeNode1 =
            findNode name1 network

        maybeNode2 =
            findNode name2 network

        maybeEdge =
            case ( maybeNode1, maybeNode2 ) of
                ( Just node1, Just node2 ) ->
                    Just (Edge node1 node2 flow)

                ( _, _ ) ->
                    Nothing
    in
        case maybeEdge of
            Nothing ->
                network

            Just edge ->
                adjoinEdge network edge


deleteEdge : String -> String -> Network -> Network
deleteEdge name1 name2 (Network nodes edges) =
    let
        newEdges =
            List.filter (edgeDoesNotMatch name1 name2) edges
    in
        Network nodes newEdges


replaceEdge : String -> String -> Float -> Network -> Network
replaceEdge name1 name2 flow network =
    let
        network2 =
            deleteEdge name1 name2 network
    in
        insertEdge name1 name2 flow network2


adjoinEdge : Network -> Edge -> Network
adjoinEdge (Network nodes edges) edge =
    Network nodes (edge :: edges)



{- Edges -}


edgeHasOrigin : Node -> Edge -> Bool
edgeHasOrigin node edge =
    equalNodes node (initialNode edge)


edgeHasTerminalNode : Node -> Edge -> Bool
edgeHasTerminalNode node edge =
    equalNodes node (terminalNode edge)


outgoingEdges : Network -> Node -> List Edge
outgoingEdges (Network nodes edges) node =
    List.filter (edgeHasOrigin node) edges


incomingEdges : Network -> Node -> List Edge
incomingEdges (Network nodes edges) node =
    List.filter (edgeHasTerminalNode node) edges



{- Flows -}


outflowFromNode : Network -> Node -> Float
outflowFromNode network node =
    (outgoingEdges network node)
        |> List.map edgeFlow
        |> List.sum


inflowToNode : Network -> Node -> Float
inflowToNode network node =
    (incomingEdges network node)
        |> List.map edgeFlow
        |> List.sum


totalFlow : Network -> Float
totalFlow (Network nodes edges) =
    let
        network =
            Network nodes edges
    in
        List.map edgeFlow edges
            |> List.sum



{-
   Display
-}


listNodes : Network -> List String
listNodes (Network nodes edges) =
    List.map name nodes


listNodesVerbose : Network -> List ( String, String )
listNodesVerbose (Network nodes edges) =
    List.map (\node -> ( name node, info node )) nodes


edgeName : Edge -> String
edgeName (Edge initialNode_ terminalNode_ flowRate) =
    (name initialNode_)
        ++ "–"
        ++ (name terminalNode_)


edgeNameWithFlow : Edge -> String
edgeNameWithFlow edge =
    (edgeName edge) ++ " " ++ (String.fromFloat (edgeFlow edge))


listEdges : Network -> List String
listEdges (Network nodes edges) =
    List.map edgeName edges


listEdgesWithFlow : Network -> List String
listEdgesWithFlow (Network nodes edges) =
    List.map edgeNameWithFlow edges


displayList : List String -> String
displayList stringList =
    String.join "\n" stringList



---
--- VISUALIZE
---
