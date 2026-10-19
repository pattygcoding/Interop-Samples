module Main (main) where

import Control.Monad (when)
import System.Exit (ExitCode (..), die)
import System.Process (readProcessWithExitCode)
import Text.Printf (printf)

-- | Interop sample: Haskell driving a Scala program.
--
-- Haskell sends the numbers to the Scala helper on stdin; the helper prints
-- their sum on stdout, and Haskell turns that into the average.
--
-- See README.md for build and run instructions.

numbers :: [Double]
numbers = [10, 20, 30, 40, 50]

main :: IO ()
main = do
    when (null numbers) $ die "error: no numbers to average"

    let count = length numbers
        payload = unwords (map show numbers)

    total <- runSumCalculator payload

    printf "The average of %d value(s) is: %.2f\n"
        count
        (total / fromIntegral count)

-- | Run the Scala helper, feeding it the numbers on stdin.
runSumCalculator :: String -> IO Double
runSumCalculator payload = do
    (exitCode, stdout, stderr) <-
        readProcessWithExitCode "scala" ["SumCalculator.scala"] payload
    case exitCode of
        ExitSuccess -> parseTotal stdout
        ExitFailure code ->
            die (printf "error: the Scala helper exited with %d: %s" code stderr)

-- | Parse the sum printed by the Scala helper.
parseTotal :: String -> IO Double
parseTotal text =
    case reads text of
        [(value, rest)] | all isSpaceChar rest -> pure value
        _ -> die ("error: unexpected output from the Scala helper: " ++ show text)
  where
    isSpaceChar c = c `elem` (" \t\r\n" :: String)

