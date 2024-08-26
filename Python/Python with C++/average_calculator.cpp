#include <iostream>
#include <vector>
#include <sstream>
#include <string>
#include <nlohmann/json.hpp>  // You will need to install this library for JSON parsing

using json = nlohmann::json;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: ./average_calculator <json_array>" << std::endl;
        return 1;
    }

    // Parse the JSON array passed from Python
    std::string json_str = argv[1];
    json numbers = json::parse(json_str);

    double sum = 0.0;
    int count = numbers.size();

    for (int i = 0; i < count; ++i) {
        sum += numbers[i];
    }

    // Calculate the average
    double average = sum / count;

    // Print the average, which will be captured by the Python script
    std::cout << average << std::endl;

    return 0;
}
