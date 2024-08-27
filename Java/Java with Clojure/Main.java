import clojure.java.api.Clojure;
import clojure.lang.IFn;

public class Main {
    public static void main(String[] args) {
        int[] numbers = {10, 20, 30, 40, 50};

        // Call the Clojure function to calculate the average
        IFn calculateAverage = Clojure.var("average-calculator", "calculate-average");
        double average = (Double) calculateAverage.invoke(numbers);

        System.out.println("The average is: " + average);
    }
}
