object AverageCalculator {
  def calculateAverage(numbers: Array[Int]): Double = {
    if (numbers.isEmpty) {
      0.0
    } else {
      val sum = numbers.sum
      sum.toDouble / numbers.length
    }
  }
}
