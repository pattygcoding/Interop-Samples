import scala.sys.process.*

/**
 * Interop sample: Scala driving a Julia program.
 *
 * Scala passes the numbers as command-line arguments to the Julia helper and
 * reads the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */

val defaultNumbers = Seq(10.0, 20.0, 30.0, 40.0, 50.0)

/** Convert command-line tokens to doubles, skipping anything invalid. */
def parseNumbers(tokens: Seq[String]): Seq[Double] =
  tokens.flatMap { token =>
    token.toDoubleOption match
      case Some(value) => Some(value)
      case None =>
        Console.err.println(s"warning: skipping non-numeric argument '$token'")
        None
  }

/** Run the Julia helper and return the average it prints. */
def calculateAverage(numbers: Seq[Double]): Double =
  val command = Seq("julia", "average_calculator.jl") ++ numbers.map(render)

  val out = new StringBuilder
  val err = new StringBuilder
  val logger = ProcessLogger(
    line => out.append(line).append('\n'),
    line => err.append(line).append('\n')
  )

  val exitCode = command.!(logger)

  if exitCode != 0 then
    val detail = err.toString.trim
    throw new RuntimeException(if detail.isEmpty then s"julia exited with code $exitCode" else detail)

  out.toString.trim.toDouble

/** Render a double without a trailing ".0" so the arguments look natural. */
def render(value: Double): String =
  if value == value.floor then value.toLong.toString else value.toString

@main def average(args: String*): Unit =
  val numbers = if args.nonEmpty then parseNumbers(args) else defaultNumbers

  if numbers.isEmpty then
    Console.err.println("error: no numbers to average")
    sys.exit(1)

  try
    val value = calculateAverage(numbers)

    // Format with the root locale so the decimal separator is stable.
    println(
      String.format(
        java.util.Locale.ROOT,
        "The average of %d value(s) is: %.2f",
        java.lang.Integer.valueOf(numbers.length),
        java.lang.Double.valueOf(value)
      )
    )
  catch
    case e: Exception =>
      Console.err.println(s"error: ${e.getMessage}")
      sys.exit(1)
