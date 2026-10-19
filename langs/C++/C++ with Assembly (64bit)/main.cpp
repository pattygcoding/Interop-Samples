/*
 * Interop sample: C++ driving a hand-written x86 assembly routine.
 *
 * `calculate_average.asm` performs the arithmetic; this translation unit only
 * supplies the numbers and prints the result. Numbers may be passed on the
 * command line, otherwise a small default data set is used.
 *
 * See README.md for build and run instructions.
 */

#include <cstdlib>
#include <exception>
#include <iomanip>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

/* Implemented in calculate_average.asm. */
extern "C" double calculate_average(const int *numbers, int count);

namespace {

constexpr int kDefaultNumbers[] = {10, 20, 30, 40, 50};

/* Convert the command line into a vector of integers, skipping anything that
 * is not a complete base-10 integer. */
std::vector<int> numbers_from_args(int argc, char *argv[])
{
    std::vector<int> numbers;
    numbers.reserve(argc > 0 ? static_cast<std::size_t>(argc - 1) : 0U);

    for (int i = 1; i < argc; ++i) {
        const std::string argument{argv[i]};
        std::size_t consumed = 0;
        try {
            const int value = std::stoi(argument, &consumed);
            if (consumed != argument.size()) {
                throw std::invalid_argument{argument};
            }
            numbers.push_back(value);
        } catch (const std::exception &) {
            std::cerr << "warning: skipping non-integer argument '" << argument << "'\n";
        }
    }

    return numbers;
}

}  // namespace

int main(int argc, char *argv[])
{
    const std::vector<int> numbers =
        argc > 1 ? numbers_from_args(argc, argv)
                 : std::vector<int>{std::begin(kDefaultNumbers), std::end(kDefaultNumbers)};

    if (numbers.empty()) {
        std::cerr << "error: no integers to average\n";
        return EXIT_FAILURE;
    }

    const double average =
        calculate_average(numbers.data(), static_cast<int>(numbers.size()));

    std::cout << "The average of " << numbers.size() << " value(s) is: " << std::fixed
              << std::setprecision(2) << average << '\n';

    return EXIT_SUCCESS;
}

