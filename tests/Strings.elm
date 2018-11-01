module Strings exposing(..)


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
