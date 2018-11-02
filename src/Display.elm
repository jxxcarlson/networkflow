module Display exposing(..)

import DisplayGraph exposing(Vertex, Graph)
import Network  exposing(Network(..))
import Dict exposing(Dict)
import Svg exposing (Svg)


networkDisplay : Float -> Network -> List (Svg msg)
networkDisplay scale network =  
  DisplayGraph.graphDisplay scale <| graphFromNetwork network

graphFromNetwork : Network -> Graph
graphFromNetwork network = 
  let   
    dict = makeNodeDicionary network
    vertices = vertexList network 
    edges = graphEdgesFromNetwork dict network   
  in 
    {vertices = vertices, edges = edges}


vertexList : Network -> List Vertex 
vertexList network = 
  List.indexedMap 
    (\index name -> {id = index + 1, label = name })
    (Network.listNodes network)


type alias NodeDictionary =  Dict String Int   

makeNodeDicionary : Network -> NodeDictionary    
makeNodeDicionary network = 
    Dict.fromList <|
      List.indexedMap 
        (\index label -> (label, index + 1))
        (Network.listNodes network)

nodeIndex : NodeDictionary -> String -> Int   
nodeIndex dict nodeName = 
  Dict.get nodeName dict 
   |> Maybe.withDefault -1



graphEdgeFromNetworkEdge : NodeDictionary -> Network.Edge -> (Int, Int)
graphEdgeFromNetworkEdge dict (Network.Edge from to _) =
  let  
    f = nodeIndex dict (Network.name from)
    t = nodeIndex dict (Network.name to)
  in  
    (f,t)

graphEdgesFromNetwork : NodeDictionary -> Network -> List (Int, Int)
graphEdgesFromNetwork dict (Network nodes edges) = 
  List.map 
    (graphEdgeFromNetworkEdge dict)
    edges