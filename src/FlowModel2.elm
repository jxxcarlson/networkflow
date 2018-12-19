module FlowModel2 exposing (..)

import SimpleGraph as SG exposing (SimpleGraph, Edge)


efficiencyOfEdge : Float -> SimpleGraph -> Edge -> Float
efficiencyOfEdge totalFlow_ graph edge =
    let
        denominator =
            (SG.outFlow edge.from graph) * (SG.inFlow edge.to graph)

        numerator =
            edge.label * totalFlow_

        logRatio =
            (logBase 2) (numerator / denominator)
    in
        roundTo 3 (edge.label * logRatio)


resilienceOfEdge : Float -> SimpleGraph -> Edge -> Float
resilienceOfEdge totalFlow_ graph edge =
    let
        denominator =
            (SG.outFlow edge.from graph) * (SG.inFlow edge.to graph)

        numerator =
            edge.label * edge.label

        logRatio =
            (logBase 2) (numerator / denominator)
    in
        edge.label * logRatio


roundTo : Int -> Float -> Float
roundTo places quantity =
    let
        factor =
            10 ^ places

        ff =
            (toFloat factor)

        q2 =
            ff * quantity

        q3 =
            round q2
    in
        (toFloat q3) / ff
