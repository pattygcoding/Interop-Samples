/*
 * Interop sample: C++ driving a Lua script.
 *
 * C++ passes the numbers as command-line arguments to `average_calculator.lua`
 * and reads the average it prints back through a pipe.
 *
 * See README.md for build and run instructions.
 */

#include <cstdio>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace {

constexpr std::size_t kMaxNumbers = 64;

/* Convert the command line into a vector of integers, skipping anything that
 * is not a complete base-10 integer. */
std::vector<int> numbers_from_args(int argc, char *argv[])
{
    std::vector<int> numbers;

    for (int i = 1; i < argc && numbers.size() < kMaxNumbers; ++i) {
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
                 : std::vector<int>{10, 20, 30, 40, 50};

    if (numbers.empty()) {
        std::cerr << "error: no integers to average\n";
        return EXIT_FAILURE;
    }

    std::string command = "lua average_calculator.lua";

    for (int number : numbers) {
        command += " " + std::to_string(number);
    }

    FILE *pipe = popen(command.c_str(), "r");

    if (pipe == nullptr) {
        std::cerr << "error: could not run '" << command << "'\n";
        return EXIT_FAILURE;
    }

    char buffer[64] = {0};
    char *got = std::fgets(buffer, sizeof(buffer), pipe);
    const int status = pclose(pipe);

    if (status != 0) {
        std::cerr << "error: the Lua helper exited with status " << status << "\n";
        return EXIT_FAILURE;
    }

    if (got == nullptr) {
        std::cerr << "error: the Lua helper produced no output\n";
        return EXIT_FAILURE;
    }

    const double average = std::strtod(buffer, nullptr);

    std::cout << "The average of " << numbers.size() << " value(s) is: " << std::fixed
              << std::setprecision(2) << average << '\n';

    return EXIT_SUCCESS;
}
