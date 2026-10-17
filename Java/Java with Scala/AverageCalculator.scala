/**
 * Interop sample: Java calling a Scala object.
 *
 * A top-level Scala `object` emits static forwarder methods, so Java sees a
 * plain static method `AverageCalculator.calculateAverage(int[])` - no special
 * Scala runtime types are required on the Java side.
 */
object AverageCalculator:

  /** Returns the arithmetic mean of `numbers`, or 0.0 when the array is empty. */
  def calculateAverage(numbers: Array[Int]): Double =
    if numbers.isEmpty then 0.0 else numbers.sum.toDouble / numbers.length

