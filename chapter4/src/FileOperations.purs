module FileOperations where

import Prelude
import Control.MonadZero (guard)
import Data.Array (head, uncons, length, filter, concatMap, (:), (..))
import Data.Foldable (foldl)
import Data.Maybe (Maybe(Nothing, Just))
import Data.Path (size, filename, root, isDirectory, Path, ls)

allFiles :: Path -> Array Path
allFiles root = root : concatMap allFiles (ls root)

allFiles' :: Path -> Array Path
allFiles' file = file : do
  child <- ls file
  allFiles' child

isEven :: Int -> Boolean
isEven 0 = true
isEven 1 = false
isEven n = isEven (n - 2)

countEvenIntsInArray :: Array Int -> Int
countEvenIntsInArray arr = case uncons arr of
  Nothing -> 0
  Just { head: x, tail: xs } -> if isEven x
    then 1 + countEvenIntsInArray xs
    else countEvenIntsInArray xs

countEven' :: Array Int -> Int
countEven' = length <<< filter isEven

squareArray :: Array Number -> Array Number
squareArray = map (\n -> n * n)

removeNegatives :: Array Number -> Array Number
removeNegatives = filter (\n -> n >= 0.0)

infix 8 filter as <$?>

removeNegativesInfix :: Array Number -> Array Number
removeNegativesInfix arr = (\n -> n >= 0.0) <$?> arr

factors :: Int -> Array (Array Int)
factors n = do
  i <- 1 .. n
  j <- i .. n
  guard $ i * j == n
  pure [i, j]

isPrime :: Int -> Boolean
isPrime n = length (factors n) == 1

cartesianProduct :: forall a. Array a -> Array a -> Array (Array a)
cartesianProduct arrA arrB = do
  a <- arrA
  b <- arrB
  pure [a, b]

triples :: Int -> Array (Array Int)
triples n = do
  a <- 1 .. n
  b <- a .. n
  c <- 2 .. n
  guard $ (a * a) + (b * b) == (c * c)
  pure [a, b, c]

factors' :: Int -> Array Int
factors' n = do
  x <- 1 .. n
  guard $ (n `mod` x) == 0
  pure x

factorizations :: Int -> Array (Array Int)
factorizations n = [n] : do
  x <- factors' n
  guard $ x > 1 && x < n
  xs <- factorizations $ n / x
  pure $ x : xs

allTrue :: Array Boolean -> Boolean
allTrue = foldl (\a x -> a && x) true

allTrue' :: Array Boolean -> Boolean
allTrue' = foldl (==) false

count :: forall a. ( a -> Boolean ) -> Array a -> Int
count p = count' 0
  where
    count' acc arr = case uncons arr of
      Nothing -> acc
      Just { head: x, tail: xs } -> if p x
        then count' (acc + 1) xs
        else count' acc xs

reverse :: forall a. Array a -> Array a
reverse = foldl (\acc n -> n : acc) []

onlyFiles :: Path -> Array Path
onlyFiles = filter (not isDirectory) <<< allFiles

largestFile :: Path -> Maybe Path
largestFile = foldl largest Nothing <<< onlyFiles
  where
    largest Nothing path = Just path
    largest (Just acc) path = if size acc > size path
      then Just acc
      else Just path

smallestFile :: Path -> Maybe Path
smallestFile = foldl smallest Nothing <<< onlyFiles
  where
    smallest Nothing path = Just path
    smallest (Just acc) path = if size acc < size path
      then Just acc
      else Just path

whereIs :: String -> Maybe Path
whereIs file = head $ do
  path <- allFiles' root
  child <- ls path
  guard $ filename child == file
  pure path
