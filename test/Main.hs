{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Circuitry
import Circuitry.Backend
import Circuitry.Gates
import Circuitry.Misc
import Circuitry.Types
import Control.Arrow (first)
import Control.Monad (zipWithM_)
import qualified Data.ByteString as BS
import Data.Typeable
import Diagrams.Prelude hiding (anon)
import Diagrams.TwoD.Arrow
import Diagrams.TwoD.Arrowheads
import Diagrams.TwoD.Layout.Constrained ((=.=))
import Diagrams.TwoD.Shapes

test :: Diagram B
test = runCircuit $ do
  [and1, or1] <- liftDias [andGate, orGate]
  withPort or1 (In 0) $ \p1 -> do
    withPort and1 (Out 0) $ \p2 -> leftOf p2 p1
    anon con $ \(s, p2) -> do
      liftCircuit $ p1 =.= p2
      arr (s, Split) (or1, In 1)
    withPort and1 (In 1) $ \p2 ->
      anon bend $ \(b1, b1p) ->
        anon bend $ \(b2, b2p) -> do
          above p2 b1p
          above p1 b2p
          leftOf b1p b2p
          spaceV 0.25 or1 b1
          arr (b1, Split) (b2, Split)
          arr (b1, Split) (and1, In 1)
          arr (b2, Split) (or1, In 1)
  withPort or1 (In 1) $ \p1 -> do
    anon con $ \(s, p2) -> do
      liftCircuit $ p1 =.= p2
  arr (and1, Out 0) (or1, In 0)
  spaceH 1 and1 or1
  return ()

main :: IO ()
main = BS.putStrLn $ toDataURL test
-- mainWith $ (test # pad 1.2 # scale 50 :: Diagram B)
