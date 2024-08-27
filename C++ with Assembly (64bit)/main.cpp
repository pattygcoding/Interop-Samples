#include <iostream>

// Declaration of the assembly function
extern "C" double calculate_average(int* numbers, int count);

int main() {
    int numbers[] = {10, 20, 30, 40, 50};
    int count = sizeof(numbers) / sizeof(numbers[0]);

    // Call the assembly function to calculate the average
    double average = calculate_average(numbers, count);

    std::cout << "The average is: " << average << std::endl;

    return 0;
}
