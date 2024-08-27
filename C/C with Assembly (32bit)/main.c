#include <stdio.h>

// Declaration of the assembly function
extern double calculate_average(int* numbers, int count);

int main() {
    int numbers[] = {10, 20, 30, 40, 50};
    int count = sizeof(numbers) / sizeof(numbers[0]);

    // Call the assembly function to calculate the average
    double average = calculate_average(numbers, count);

    printf("The average is: %lf\n", average);

    return 0;
}
