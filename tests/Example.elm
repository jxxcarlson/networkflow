module Example exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(..))
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Network exposing(..)
import Decoder exposing(..)
import Json.Decode exposing(decodeString)

doTest comment inputExpression outputExpression =
    test comment <|
        \_ ->
            Expect.equal inputExpression outputExpression

doFloatTest comment inputExpression outputExpression =
    test comment <|
        \_ ->
            Expect.within (Relative 0.0001) inputExpression outputExpression



net = buildNetwork [u1, u2, u3, u4] [e14, e12, e43, e23 ] 


netAsJson = """
  {
    "nodes": [
      {"name": "U1" }, 
      {"name": "U2" },
      {"name": "U3" }, 
      {"name": "U4" }
    ], 
    "edges": [
        {
          "initialNode": "U1", 
          "terminalNode": "U4",
          "flow": 30
        },
        {
          "initialNode": "U1", 
          "terminalNode": "U2",
          "flow": 90.4
        },
        {
          "initialNode": "U4", 
          "terminalNode": "U3",
          "flow": 22
        },
        {
          "initialNode": "U2", 
          "terminalNode": "U3",
          "flow": 31.4
        }
    ]
  }

"""

nodeAAsJson = """
  {"name": "A" }
"""

nodeBAsJson = """
  {"name": "B"}
"""

edgeABAsJson = """
  {
     "initialNode": {"name": "A" }, 
     "terminalNode": {"name": "B" },
     "flow": 17.3
  }
"""

suite : Test
suite =
    describe "The Network module" [
          creationSuite 
        , flowSuite
        , jsonSuite
    ]

creationSuite = describe "Create nodes, edges, networks" 
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
        ] 

flowSuite = describe "Test flows" 
    [ 
      doFloatTest 
        "1. totalFlow"
        (totalFlow net)
        (173.8)
    , doFloatTest
        "2. efficiency"
        (efficiency net)
        (154.677)
    , doFloatTest
        "3. resilience"
        (resilience net)
        (149.719)
    , doFloatTest
        "4. alpha"
        (alpha net)
        (0.50814)
    , doFloatTest
        "5. sustainability"
        (sustainability net)
        (0.9699)
    ] 

jsonSuite = describe "Json decoders"
  [
    doTest
      "1. decode Nodge"
      (decodeString decodeNode nodeA)
      (Ok (Node "A"))


  ]