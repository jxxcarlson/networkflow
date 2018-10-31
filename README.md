# Network

The Network module implements the Ulanowicz et al for
efficiency, reliability, and sustainability of networks.
The module has been written using Elm 0.19 and will
have to be tested for 0.18. Minor changes may be required.

The code is in `src/Network.elm`. A network is described
by nodes and edges. Here are the type definitions:

```
type Node =
  Node String (Maybe String)

type Edge =
  Edge Node Node Float

type Network =
  Network (List Node) (List Edge)
```

## Tests

As an example, we create a small network by hand:

```
u1 = createNode "U1"
u2 = createNode "U2"
u3 = createNode "U3"
u4 = createNode "U4"

e14 = createEdge u1 u4 30
e12 = createEdge u1 u2 90.4
e43 = createEdge u4 u3 22
e23 = createEdge u2 u3 31.4

net = buildNetwork [u1, u2, u3, u4] [e14, e12, e43, e23 ]
```

One can make various computations:

```
$ elm repl
> import Network

> listNodes net
["U1","U2","U3","U4"]

> listEdges net
["U1->U4","U1->U2","U4->U3","U2->U3"]

> listEdgesWithFlow net
["U1->U4: 30","U1->U2: 90.4","U4->U3: 22","U2->U3: 31.4"]

> efficiency net
154.677

> resilience net
149.719 : Float

> alpha net
0.5081441618940449 : Float

> sustainabilityPercentage net
96.99 : Float
```

One can also inspect the structure of the network:

```
> listNodes net
  ["U1","U2","U3","U4"]

> listEdgesWithFlow net
["U1->U4: 30","U1->U2: 90.4","U4->U3: 22","U2->U3: 31.4"]
```

## Experiments

### Adding/deleting an edge

There are facilities for editing a given network in
order to experiment with changes in it.

```
> net2 = insertEdge "U1" "U3" 20 net

> sustainabilityPercentage net2
81.11 : Float

> sustainabilityPercentage net
96.99 : Float
```

To delete an edge, use

```
deleteEdge name1 name2  network
```

### Modifying an edge

```
> net2 = replaceEdge "U1" "U4" 10 net

> sustainabilityPercentage net2
91.54 : Float
```

## JSON Decoders

Below is a JSON representation of netwrok
in the example above. One can can test it like this:

```
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
```
