import scala.io.Source
import java.io.PrintWriter

object SumCalculator {
  def main(args: Array[String]): Unit = {
    // Read the numbers from the file
    val numbers = Source.fromFile("numbers.txt").getLines().flatMap(_.split(" ")).map(_.toDouble).toList

    // Calculate the sum
    val sum = numbers.sum

    // Write the sum to a result file
    val writer = new PrintWriter("result.txt")
    writer.write(sum.toString)
    writer.close()
  }
}
