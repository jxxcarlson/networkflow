module Strings exposing(..)


nodeAAsJson = """
  {"name": "A" }
"""

nodeBAsJson = """
  {"name": "B"}
"""

edgeABAsJson = """
  {
     "from": {"name": "A" }, 
     "to": {"name": "B" },
     "amount": 17.3
  }
"""

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
          "from": "U1", 
          "to": "U4",
          "amount": 30
        },
        {
          "from": "U1", 
          "to": "U2",
          "amount": 90.4
        },
        {
          "from": "U4", 
          "to": "U3",
          "amount": 22
        },
        {
          "from": "U2", 
          "to": "U3",
          "amount": 31.4
        }
    ]
  }

"""


simpleEdgeListAsJson = """
   { "edges": [
        {
          "from": "U1", 
          "to": "U4",
          "amount": 30
        },
        {
          "from": "U1", 
          "to": "U2",
          "amount": 90.4
        },
        {
          "from": "U4", 
          "to": "U3",
          "amount": 22
        },
        {
          "from": "U2", 
          "to": "U3",
          "amount": 31.4
        }
    ]
  }
"""



netAsString = "U1, U4, 30; U1, U2, 90.4; U4, U3, 22; U2, U3, 31.4;"

---
--- Json.Decode Tests
---

nodeA = """
  {"name": "A" }
"""

nodeB = """
  {"name": "B"}
"""

edgeAB = """
  {
     "from": {"name": "A" }, 
     "to": {"name": "B" },
     "amount": 17.3
  }
"""

simpleEdgeAB = """
  {
     "from": "A", 
     "to": "B",
     "amount": 17.3
  }
"""

tinyNetAsJson = """
  { 
    "nodes": [
      {"name": "A" }, 
      {"name": "B" }
    ], 
    "edges": [
        {
          "from": "A", 
          "to": "B",
          "amount": 17.3
        }
    ]

  }
"""