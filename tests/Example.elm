module Example exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(..))
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Network exposing(..)
import Decoder exposing(..)
import Json.Decode exposing(decodeString)
import Strings exposing(..)
import Flow exposing(..)

doTest comment inputExpression outputExpression =
    test comment <|
        \_ ->
            Expect.equal inputExpression outputExpression

doFloatTest comment inputExpression outputExpression =
    test comment <|
        \_ ->
            Expect.within (Relative 0.0001) inputExpression outputExpression


u1 = createNode "U1"
u2 = createNode "U2"
u3 = createNode "U3"
u4 = createNode "U4"

e14 = createEdge u1 u4 30
e12 = createEdge u1 u2 90.4
e43 = createEdge u4 u3 22
e23 = createEdge u2 u3 31.4


net = buildNetwork [u1, u2, u3, u4] [e14, e12, e43, e23 ] 

--
  -- NETWORK TEST DATA
--


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
      "1. decode Node"
      (decodeString decodeNode nodeAAsJson)
      (Ok (Node "A"))
    , doTest
      "2. decode Edge"
      (decodeString decodeEdge edgeABAsJson)
      (Ok (Edge (Node "A") (Node "B") 17.3))

  ]