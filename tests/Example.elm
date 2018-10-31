module Example exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(..))
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Network exposing(..)

doTest comment inputExpression outputExpression =
    test comment <|
        \_ ->
            Expect.equal inputExpression outputExpression

doFloatTest comment inputExpression outputExpression =
    test comment <|
        \_ ->
            Expect.within (Relative 0.0001) inputExpression outputExpression



net = buildNetwork [u1, u2, u3, u4] [e14, e12, e43, e23 ] 


suite : Test
suite =
    describe "The Network module"
        [ describe "Create nodes, edges, networks" 
            [ 
              doTest
                "1. Create node"
                (name (createNode "A"))
                ("A")
            , doTest
                "2. Equal nodes"
                (equalNodes (createNode "A") (createNode "A"))
                (True)
            , doTest
                "2. Unequal nodes"
                (equalNodes (createNode "A") (createNode "B"))
                (False)
            , doTest
                "3. Build network and count nodes"
                (nodeCount net)
                (4)
            , doTest
                "4. Build network and count edges"
                (edgeCount net)
                (4)
            , doTest
                "5. insertEdge"
                ((edgeCount (insertEdge "U1" "U3" 10 net)))
                (5)
             , doTest
                "6. deleteEdge"
                ((edgeCount (deleteEdge "U1" "U4" net)))
                (3)
            , doTest
                "7. replaceEdge"
                ((Maybe.map edgeFlow (getEdge "U1" "U4" (replaceEdge "U1" "U4" 1.234 net))))
                (Just 1.234)
            , doFloatTest
                "8. totalFlow"
                (totalFlow net)
                (173.8)
            , doFloatTest
                "9. efficiency"
                (efficiency net)
                (154.677)
            , doFloatTest
                "10. resilience"
                (resilience net)
                (149.719)
        
        ]
    ]