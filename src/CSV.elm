module CSV exposing(networkFromString, example)


import Parser exposing (..)
import Parser.Extras exposing(many)
import Tools exposing(unique)
import Network
    exposing
        ( Network(..)
        , Node
        , SimpleEdge(..)
        , Edge(..)
        , createNode
        , sourceNameOfSimpleEdge
        , sinkNameOfSimpleEdge
        )

import NetworkParser exposing (identifier, nodesFromString, edgeListFromString)

networkFromString : String -> Network
networkFromString str =
    Network (nodesFromString str) (edgeListFromString str)

nodeNamesFromString : String -> List String
nodeNamesFromString str =
    let
        simpleEdgeList =
            simpleEdgeListFromString str

        sourceNodeNames =
            simpleEdgeList |> List.map sourceNameOfSimpleEdge

        sinkNodeNames =
            simpleEdgeList |> List.map sinkNameOfSimpleEdge
    in
        sourceNodeNames ++ sinkNodeNames |> unique |> List.sort


nodesFromString : String -> List Node
nodesFromString str =
    nodeNamesFromString str
        |> List.map (\str_ -> createNode str_ "")

normalize: String -> String
normalize str = 
   str   
     |> String.trim 
     |> \x -> x ++ "\n"

edgeListFromString : String -> List Edge
edgeListFromString str =
    simpleEdgeListFromString (str |> normalize)
        |> Network.edgeListFromSimpleEdgeList

simpleEdgeListFromString : String -> List SimpleEdge
simpleEdgeListFromString str =
    case run simpleEdgeListParser str of
        Err _ ->
            []

        Ok edgeList ->
            edgeList

simpleEdgeListParser : Parser (List SimpleEdge)
simpleEdgeListParser =
    many simpleEdgeParser


simpleEdgeParser : Parser SimpleEdge
simpleEdgeParser =
    succeed SimpleEdge
        |= identifier
        |. symbol ","
        |. spaces
        |= identifier
        |. symbol ","
        |. spaces
        |= float
        |. spaces

example = "   \n\nA,B,23\nA,C,10\nB,D,40\nC,D,5  \n"
