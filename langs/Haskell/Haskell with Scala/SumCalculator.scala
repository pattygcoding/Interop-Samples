import scala.io.StdIn

/**
 * Interop sample: reads whitespace-separated numbers from standard input and
 * prints their sum to standard output.
 *
 * Invoked by `main.hs`; see README.md for build and run instructions.
 */
object SumCalculator:

  def main(args: Array[String]): Unit =
    val line = Option(StdIn.readLine()).getOrElse("")

    val numbers = line
      .trim
      .split("\\s+")
      .filter(_.nonEmpty)
      .map(_.toDouble)

    if numbers.isEmpty then
      Console.err.println("error: no numbers on stdin")
      sys.exit(1)

    println(numbers.sum)

