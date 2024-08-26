import java.util.Arrays;
import org.json.JSONArray;

public class AverageCalculator {
    public static void main(String[] args) {
        // Parse the JSON array passed from Python
        JSONArray jsonArray = new JSONArray(args[0]);

        double sum = 0;
        for (int i = 0; i < jsonArray.length(); i++) {
            sum += jsonArray.getDouble(i);
        }

        // Calculate the average
        double average = sum / jsonArray.length();

        // Print the average, which will be captured by the Python script
        System.out.println(average);
    }
}
