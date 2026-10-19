/*
 * Interop sample: reads whitespace-separated numbers from standard input and
 * writes their arithmetic mean to standard output.
 *
 * Invoked by main.py; see README.md for build and run instructions.
 */

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <vector>

int main()
{
    std::vector<double> numbers;
    double value = 0.0;

    while (std::cin >> value) {
        numbers.push_back(value);
    }

    // The loop ends on EOF (fine) or on a malformed token (an error).
    if (!std::cin.eof()) {
        std::cerr << "error: input contained a non-numeric value\n";
        return EXIT_FAILURE;
    }

    if (numbers.empty()) {
        std::cerr << "error: no numbers on stdin\n";
        return EXIT_FAILURE;
    }

    double sum = 0.0;
    for (double number : numbers) {
        sum += number;
    }

    // 17 significant digits round-trip an IEEE-754 double exactly.
    std::cout << std::setprecision(17) << (sum / static_cast<double>(numbers.size())) << '\n';

    return EXIT_SUCCESS;
}

