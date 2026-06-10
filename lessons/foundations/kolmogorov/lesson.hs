-- | Lesson: Kolmogorov's axioms
-- Topic:   foundations
-- Run:     runghc lesson.hs
module Main where

import Data.List (nub)
import Text.Printf (printf)

-- ---------------------------------------------------------------------------
-- Types
-- ---------------------------------------------------------------------------

-- | One completed connection (Zeek conn.log-style fields).
data Flow = Flow
  { origBytes :: Int,
    respBytes :: Int,
    durationSec :: Double
  }

-- | Elementary outcomes in sample space Omega.
data FlowClass = Benign | Malware | Unknown
  deriving (Eq, Ord, Enum, Bounded, Show)

-- | Probability in [0, 1] with fixed decimal display.
newtype Probability = Probability Double
  deriving (Eq, Ord, Num, Fractional)

instance Show Probability where
  show (Probability p) = printf "%.2f" p

-- | An event: a set of outcomes (no duplicates).
newtype Event = Event [FlowClass]

-- | Build an event from a list of outcomes, removing duplicates.
event :: [FlowClass] -> Event
event = Event . nub

-- ---------------------------------------------------------------------------
-- Measure
-- ---------------------------------------------------------------------------

-- | P({outcome}) for each outcome in Omega.
atomicProbability :: FlowClass -> Probability
atomicProbability Benign = 0.9
atomicProbability Malware = 0.05
atomicProbability Unknown = 0.05

-- | P(E) = sum of atomic probabilities over outcomes in E.
probabilityOf :: Event -> Probability
probabilityOf (Event outcomes) =
  sum [atomicProbability c | c <- outcomes]

-- | Omega: all elementary outcomes.
sampleSpace :: Event
sampleSpace = event [minBound .. maxBound]

-- | Malware or unknown — matches the lesson.qmd worked example.
suspicious :: Event
suspicious = event [Malware, Unknown]

-- ---------------------------------------------------------------------------
-- Axiom checks
-- ---------------------------------------------------------------------------

data AxiomChecks = AxiomChecks
  { allNonNegative :: Bool,
    sumsToOne :: Bool,
    additiveWhenDisjoint :: Bool
  }
  deriving Show

checkDisjointAdditivity :: Event -> Event -> Bool
checkDisjointAdditivity (Event a) (Event b) =
  let disjoint = all (`notElem` b) a
      union = event (a ++ b)
   in not disjoint
        || abs (probabilityOf union - (probabilityOf (Event a) + probabilityOf (Event b))) < 1e-6

runAxiomChecks :: AxiomChecks
runAxiomChecks =
  AxiomChecks
    { allNonNegative = all (>= 0) [atomicProbability c | c <- [minBound .. maxBound]],
      sumsToOne = abs (probabilityOf sampleSpace - 1) < 1e-6,
      additiveWhenDisjoint = checkDisjointAdditivity (event [Benign]) (event [Malware])
    }

-- ---------------------------------------------------------------------------
-- Classification
-- ---------------------------------------------------------------------------

classifyFlow :: Flow -> FlowClass
classifyFlow (Flow o r d)
  | d <= 0 || o + r == 0 = Unknown
  | o < 2000 && r < 2000 = Malware
  | otherwise = Benign

demoFlows :: [(String, Flow)]
demoFlows =
  [ ("browser HTTPS session", Flow 12000 180000 45),
    ("beacon-like check-in", Flow 400 380 60),
    ("failed / no payload", Flow 0 0 0)
  ]

-- ---------------------------------------------------------------------------
-- Printing
-- ---------------------------------------------------------------------------

printHeader :: String -> IO ()
printHeader title = do
  putStrLn ""
  putStrLn title
  putStrLn (replicate (length title) '-')

formatFlow :: Flow -> String
formatFlow (Flow o r d) =
  printf "orig=%d resp=%d dur=%.0fs" o r d

printAtomicWeights :: IO ()
printAtomicWeights = do
  printHeader "Atomic probabilities P({class})"
  mapM_
    ( \c ->
        printf "  %-7s  %s\n" (show c) (show (atomicProbability c))
    )
    [minBound .. maxBound]

printAxiomResults :: IO ()
printAxiomResults = do
  let checks = runAxiomChecks
  printHeader "Kolmogorov axiom checks"
  printf "  Non-negativity:        %s\n" (show (allNonNegative checks))
  printf "  Normalization:         %s\n" (show (sumsToOne checks))
  printf "  Disjoint additivity:   %s\n" (show (additiveWhenDisjoint checks))

printFlowExample :: (String, Flow) -> IO ()
printFlowExample (name, flow) = do
  let outcome = classifyFlow flow
  printf
    "  %-24s  %s  ->  %-7s  (P({%s}) = %s)\n"
    name
    (formatFlow flow)
    (show outcome)
    (show outcome)
    (show (probabilityOf (event [outcome])))

printCompoundEvents :: IO ()
printCompoundEvents = do
  printHeader "Compound events (disjoint unions)"
  printf "  P(malware or unknown) = %s\n" (show (probabilityOf suspicious))

-- ---------------------------------------------------------------------------
-- Main
-- ---------------------------------------------------------------------------

main :: IO ()
main = do
  printAtomicWeights
  printAxiomResults
  printHeader "Classify example flows"
  mapM_ printFlowExample demoFlows
  printCompoundEvents
