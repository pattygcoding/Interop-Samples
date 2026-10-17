module Main (main) where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.IO (hPutStrLn, stderr)
import Text.Printf (printf)

-- | Interop sample: reads integers from the command line and prints their
-- arithmetic mean.
--
-- Errors go to stderr and exit status 1; the Erlang side merges stderr into
-- the port stream, so it reports them back to the user.
--
-- Invoked by main.escript; see README.md for build and run instructions.

main :: IO ()
main = do
    args <- getArgs

    case traverse parseInteger args of
        Left token -> do
            hPutStrLn stderr (printf "error: '%s' is not an integer" token)
            exitFailure
        Right [] -> do
            hPutStrLn stderr "error: no numbers supplied"
            exitFailure
        Right numbers -> do
            let count = length numbers
                average = fromIntegral (sum numbers) / fromIntegral count :: Double

            -- A fixed-notation result keeps it easy to parse on the other side.
            printf "%.10f\n" average
            exitSuccess

parseInteger :: String -> Either String Integer
parseInteger token =
    case reads token of
        [(value, "")] -> Right value
        _ -> Left token
