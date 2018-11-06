module SvgText exposing(..)

import Svg exposing (..)
import Svg.Attributes exposing (..)


textDisplay : Int -> Float -> Float -> String -> Svg msg 
textDisplay fontSize_ x_ y_ content = 
  text_ [ 
      x <| String.fromFloat x_ 
    , y <| String.fromFloat y_
    , fontSize <| String.fromInt fontSize_
    ] [text content]