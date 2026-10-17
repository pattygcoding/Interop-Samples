/*
 * Interop sample: prints the arithmetic mean of the numbers given on the
 * command line.
 *
 * Invoked by main.v; see README.md for build and run instructions.
 */

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>

int main(int argc, char *argv[])
{
    if (argc < 2) {
        std::cerr << "error: no numbers supplied\n";
        return EXIT_FAILURE;
    }

    double total = 0.0;
    int count = 0;

    for (int i = 1; i < argc; ++i) {
        const std::string argument{argv[i]};
        std::size_t consumed = 0;

        try {
            const double value = std::stod(argument, &consumed);

            if (consumed != argument.size()) {
                throw std::invalid_argument{argument};
            }

            total += value;
            ++count;
        } catch (const std::exception &) {
            std::cerr << "error: '" << argument << "' is not a number\n";
            return EXIT_FAILURE;
        }
    }

    std::cout << std::fixed << std::setprecision(2) << (total / count) << '\n';

    return EXIT_SUCCESS;
}
