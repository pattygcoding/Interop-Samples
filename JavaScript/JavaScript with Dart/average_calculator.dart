import 'dart:convert';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart average_calculator.dart <json_array>');
    return;
  }

  // Parse the JSON array passed from JavaScript
  String jsonArray = args[0];
  List<dynamic> numbers = jsonDecode(jsonArray);

  // Convert dynamic list to a list of doubles
  List<double> doubleNumbers = numbers.map((n) => n.toDouble()).toList();

  // Calculate the average
  double sum = doubleNumbers.reduce((a, b) => a + b);
  double average = sum / doubleNumbers.length;

  // Print the average, which will be captured by the JavaScript script
  print(average);
}
