/**
 * Interop sample: prints the arithmetic mean of the numbers given on the command
 * line.
 *
 * Invoked by main.js; see README.md for build and run instructions.
 */

@main def average(args: String*): Unit =
  if args.isEmpty then
    Console.err.println("error: no numbers supplied")
    sys.exit(1)

  val numbers = args.map { token =>
    token.toDoubleOption match
      case Some(value) => value
      case None =>
        Console.err.println(s"error: '$token' is not a number")
        sys.exit(1)
  }

  // Format with the root locale so the decimal separator is stable.
  println(
    String.format(
      java.util.Locale.ROOT,
      "%.2f",
      java.lang.Double.valueOf(numbers.sum / numbers.length)
    )
  )
