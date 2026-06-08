-- | Lesson: <Title>
-- Topic:   <topic>
-- Run:     runghc lesson.hs
module Main where

-- Replace with lesson content.
example :: Int -> Int
example n = n * n

main :: IO ()
main = do
  putStrLn "Mathy lesson"
  print (example 5)
