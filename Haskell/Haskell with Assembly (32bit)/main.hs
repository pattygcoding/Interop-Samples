module Main (main) where

import Control.Exception (finally)
import Control.Monad (when)
import System.Directory
    ( createDirectoryIfMissing
    , getTemporaryDirectory
    , removeDirectoryRecursive
    )
import System.Exit (ExitCode (..), die)
import System.FilePath ((</>))
import System.Process (readProcessWithExitCode)
import Text.Printf (printf)

-- | Interop sample: Haskell driving a hand-written assembly program.
--
-- Haskell writes the numbers to a scratch file, runs the @sum_calc@ helper
-- (built from @sum_calc.asm@) which adds them up and writes the total to a
-- second file, then prints the average.
--
-- See README.md for build and run instructions.

numbers :: [Int]
numbers = [10, 20, 30, 40, 50]

main :: IO ()
main = do
    when (null numbers) $ die "error: no numbers to average"

    let count = length numbers

    total <- withScratchDirectory $ \dir -> do
        let inputPath = dir </> "numbers.txt"
            outputPath = dir </> "result.txt"
        writeFile inputPath (unwords (map show numbers))
        runSumCalculator inputPath outputPath
        readFile outputPath >>= parseTotal

    printf "The average of %d value(s) is: %.2f\n"
        count
        (fromIntegral total / fromIntegral count :: Double)

-- | Run the assembly helper and fail loudly if it does not exit cleanly.
runSumCalculator :: FilePath -> FilePath -> IO ()
runSumCalculator inputPath outputPath = do
    (exitCode, _stdout, stderr) <-
        readProcessWithExitCode "./sum_calc" [inputPath, outputPath] ""
    case exitCode of
        ExitSuccess -> pure ()
        ExitFailure code ->
            die (printf "error: sum_calc exited with %d: %s" code stderr)

-- | Parse the integer the helper wrote to the result file.
parseTotal :: String -> IO Int
parseTotal text =
    case reads text of
        [(value, rest)] | all isSpaceChar rest -> pure value
        _ -> die ("error: unexpected output from sum_calc: " ++ show text)
  where
    isSpaceChar c = c `elem` (" \t\r\n" :: String)

-- | Create a scratch directory that is always removed again.
withScratchDirectory :: (FilePath -> IO a) -> IO a
withScratchDirectory action = do
    base <- getTemporaryDirectory
    let dir = base </> "haskell-asm-interop"
    createDirectoryIfMissing True dir
    action dir `finally` removeDirectoryRecursive dir

