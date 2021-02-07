module Circuitry.Machinery where

import Circuitry.Backend
import Circuitry.Misc
import Circuitry.Types
import Control.Arrow (second)
import Diagrams.Prelude

machine :: [String] -> [String] -> String -> DiaID s -> Diagram B
machine = machine' (repeat inputWire)

machine' :: [Diagram B] -> [String] -> [String] -> String -> DiaID s -> Diagram B
machine' wires ins outs labelText n =
  inputNumStack ||| inputStack
    ||| (rect width height <> inLabels <> outLabels <> label)
    ||| outputStack
    ||| outputNumStack
  where
    vspacing = 2.5
    hspacing = width / 2 - textSize
    width =
      ( fromIntegral
          ( maximum (fmap length ins)
              + maximum (fmap length outs)
          )
          * textSize
      )
        + (fromIntegral (length labelText) * labelSize)
        + 0.5
    label = text labelText # scale labelSize
    height = minimum [heightOf outs, heightOf ins, negate $ textSize + 0.2] / vspacing * 1.35
    -- TODO(sandy): this is negative. wtf?
    heightOf ls = - vspacing * fromIntegral (length ls - 1) / 2
    stack as = foldl (\b a -> b # translate (r2 (0, vspacing)) <> a) nothing as
    objStack as f = stack (fmap f as) # translate (r2 (0, heightOf as)) # scaleY textSize
    inputNumStack = objStack (renumber ins) $ \a -> mkCon n (In a)
    inputStack = objStack (zip ins (fmap (scaleY (1 / textSize)) wires)) $ \(a, d) -> mkCon n (Named a) ||| d
    outputStack = objStack outs $ \a -> mkCon n (Named a)
    outputNumStack = objStack (renumber outs) $ \a -> mkCon n (Out a)
    textStack ls = stack (fmap text ls) # translate (r2 (0, heightOf ls)) # scale textSize
    inLabels = textStack ins # translate (r2 (- hspacing, 0))
    outLabels = textStack outs # translate (r2 (hspacing, 0))
    renumber = zipWith const [0 ..]

blackBox :: String -> DiaID s -> Diagram B
blackBox str n = machine [""] [""] str n # bold
