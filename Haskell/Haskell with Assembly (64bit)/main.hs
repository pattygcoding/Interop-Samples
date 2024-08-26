import System.IO
import System.Process

main :: IO ()
main = do
    -- Define the list of numbers
    let numbers = [10.0, 20.0, 30.0, 40.0, 50.0]
    
    -- Write the numbers to a file for the assembly program to read
    writeFile "numbers.txt" (unwords $ map show numbers)
    
    -- Call the assembly program to calculate the sum
    _ <- system "./sum_calc"

    -- Read the sum from the result file
    sumResult <- readFile "result.txt"
    let sumValue = read sumResult :: Double

    -- Calculate the average
    let count = fromIntegral (length numbers)
    let average = sumValue / count

    -- Print the average
    putStrLn $ "The average is: " ++ show average
