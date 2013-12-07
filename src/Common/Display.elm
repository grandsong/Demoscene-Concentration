module Common.Display where

{-| -}

import Common.Types(Positioned,Point,point2D)
import Common.Algorithms(sortBy)

(gameWidth,gameHeight) = (200,200)

type PositionedForm = Positioned {f:Form}

{-| Since the game is always scaled maximally into the window
(keeping its aspect ratio), the mouse and touch positions
have to be converted to game positions. -}
winPosToGamePos : Positioned a -> (Int,Int) -> Point
winPosToGamePos pos size =
  let
    intPairToFloatPair (a, b) = (toFloat a, toFloat b)
    (winX, winY) = (pos.x, pos.y)
    (sizeX, sizeY) = intPairToFloatPair size
    (middleX, middleY) = (sizeX / 2, sizeY / 2)
    factor = gameScale size (gameWidth,gameHeight)
  in
    point2D ((winX - middleX) / factor) ((middleY - winY) / factor)

{-| Calculate factor by which the game is scaled visually onto the screen. -}
gameScale : (Int,Int) -> (Float,Float) -> Float
gameScale (winW, winH) (gameW,gameH) =
  min (toFloat winW / gameW) (toFloat winH / gameH)

-- todo take out? use maybes instead?
dummyForm = rect 0 0 |> filled (rgba 0 0 0 0)

decomposeColor : Color -> (Int,Int,Int,Float)
decomposeColor (Color r g b a) = (r,g,b,a)

positionedForm : Form -> Positioned a -> PositionedForm
positionedForm f {x,y,z} = { f=f, x=x, y=y, z=z }

displayPositionedForm : PositionedForm -> Form
displayPositionedForm {f,x,y} = f |> move (x, y)

isPosOK : Positioned a -> Bool
isPosOK {x,y,z} = z < -1 && x >= -100 && x <= 100 && y >= -100 && y <= 100

displayPositionedForms : [PositionedForm] -> Form
displayPositionedForms fs =
    fs
    |> sortBy (\a b -> a.z > b.z)
    |> filter isPosOK
    |> map displayPositionedForm |> group

{-| Draw game maximized into the window. -}
displayFullScreen : (a -> Form) -> a -> (Int,Int) -> Element
displayFullScreen displayFunc state (w,h) =
  let
    factor = gameScale (w,h) (gameWidth,gameHeight)
  in
    collage w h [ displayFunc state |> scale factor ]