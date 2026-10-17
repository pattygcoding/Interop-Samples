-- | Interop sample: Haskell driving a compiled Nim program.
--
-- Haskell passes the numbers as command-line arguments to the Nim helper and
-- reads the average it prints back from stdout.
--
-- See README.md for build and run instructions.

module Main (main) where

import Data.List (dropWhileEnd)
import System.Environment (getArgs)
import System.Exit (ExitCode (..), exitWith)
import System.Info (os)
import System.IO (hPutStrLn, stderr)
import System.Process (readProcessWithExitCode)
import Text.Printf (printf)

defaultNumbers :: [Double]
defaultNumbers = [10, 20, 30, 40, 50]

-- | The helper is built beside this program, with an .exe suffix on Windows.
executable :: String
executable = "average_calculator" ++ (if os == "mingw32" then ".exe" else "")

-- | Report a failure and stop with a non-zero exit status.
die :: String -> IO a
die message = do
    hPutStrLn stderr ("error: " ++ message)
    exitWith (ExitFailure 1)

-- | Convert command-line tokens to doubles, skipping anything invalid.
parseNumbers :: [String] -> IO [Double]
parseNumbers tokens = do
    parsed <- mapM parseOne tokens
    pure (concat parsed)
  where
    parseOne token =
        case reads token of
            [(value, trailing)] | all isSpace trailing -> pure [value]
            _ -> do
                hPutStrLn stderr (printf "warning: skipping non-numeric argument '%s'" token)
                pure []

isSpace :: Char -> Bool
isSpace c = c `elem` (" \t\r\n" :: String)

trim :: String -> String
trim = dropWhileEnd isSpace . dropWhile isSpace

-- | Run the Nim helper and return the average it prints.
calculateAverage :: [Double] -> IO Double
calculateAverage numbers = do
    (exitCode, output, errors) <-
        readProcessWithExitCode executable (map show numbers) ""
    case exitCode of
        ExitSuccess -> parseAverage output
        ExitFailure code -> do
            let detail = trim errors
            die
                ( if null detail
                    then printf "the Nim helper exited with code %d" code
                    else detail
                )

-- | Parse the average printed by the Nim helper.
parseAverage :: String -> IO Double
parseAverage text =
    case reads text of
        [(value, trailing)] | all isSpace trailing -> pure value
        _ -> die ("unexpected output from the Nim helper: " ++ show text)

main :: IO ()
main = do
    args <- getArgs
    numbers <- if null args then pure defaultNumbers else parseNumbers args

    if null numbers
        then die "no numbers to average"
        else do
            average <- calculateAverage numbers
            printf "The average of %d value(s) is: %.2f\n" (length numbers) average
