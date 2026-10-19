module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStrLn, stderr)
import Text.Printf (printf)

-- | Interop sample: reads numbers from the command line and prints their
-- arithmetic mean.
--
-- Invoked by main.dart; see README.md for build and run instructions.

main :: IO ()
main = do
    args <- getArgs

    case traverse parseNumber args of
        Left token -> do
            hPutStrLn stderr (printf "error: '%s' is not a number" token)
            exitFailure
        Right [] -> do
            hPutStrLn stderr "error: no numbers supplied"
            exitFailure
        Right numbers -> do
            let count = length numbers
                average = sum numbers / fromIntegral count :: Double

            printf "%.2f\n" average
            exitSuccess

parseNumber :: String -> Either String Double
parseNumber token =
    case reads token of
        [(value, "")] -> Right value
        _ -> Left token
