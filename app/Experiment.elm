

import Svg exposing (..)
import Svg.Attributes exposing (..)


textDisplay : Int -> Float -> Float -> String -> Svg msg 
textDisplay fontSize_ x_ y_ content = 
  text_ [ 
      x <| String.fromFloat x_ 
    , y <| String.fromFloat y_
    , fontSize <| String.fromInt fontSize_
    ] [text content]

main =
  svg
    [ width "300"
    , height "300"
    , viewBox "0 0 300 300"
    ]
    [ 
       textDisplay 24 10 40 "Fruit:"
     , textDisplay 24 10 80 "Bananas"
     , textDisplay 24 10 120 "Apples"
    ]