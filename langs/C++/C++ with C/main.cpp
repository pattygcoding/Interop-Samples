/*
 * Interop sample: C++ driving a compiled C program.
 *
 * C++ passes the numbers as command-line arguments to the C helper and reads the
 * average it prints back through a pipe.
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

/* A shell only finds the helper in the current directory if the name says so,
 * and Windows appends the .exe suffix on its own. */
#ifdef _WIN32
constexpr const char *kExecutable = "average_calculator.exe";
#else
constexpr const char *kExecutable = "./average_calculator";
#endif

/* Convert the command line into a vector of doubles, skipping anything that is
 * not a complete number. */
std::vector<double> numbers_from_args(int argc, char *argv[])
{
    std::vector<double> numbers;

    for (int i = 1; i < argc; ++i) {
        const std::string argument{argv[i]};
        std::size_t consumed = 0;

        try {
            const double value = std::stod(argument, &consumed);

            if (consumed != argument.size()) {
                throw std::invalid_argument{argument};
            }

            numbers.push_back(value);
        } catch (const std::exception &) {
            std::cerr << "warning: skipping non-numeric argument '" << argument << "'\n";
        }
    }

    return numbers;
}

}  // namespace

int main(int argc, char *argv[])
{
    const std::vector<double> numbers =
        argc > 1 ? numbers_from_args(argc, argv) : std::vector<double>{10, 20, 30, 40, 50};

    if (numbers.empty()) {
        std::cerr << "error: no numbers to average\n";
        return EXIT_FAILURE;
    }

    std::string command = kExecutable;

    for (double number : numbers) {
        char buffer[32] = {0};
        std::snprintf(buffer, sizeof(buffer), " %g", number);
        command += buffer;
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
        std::cerr << "error: the C helper exited with status " << status << "\n";
        return EXIT_FAILURE;
    }

    if (got == nullptr) {
        std::cerr << "error: the C helper produced no output\n";
        return EXIT_FAILURE;
    }

    const double average = std::strtod(buffer, nullptr);

    std::cout << "The average of " << numbers.size() << " value(s) is: " << std::fixed
              << std::setprecision(2) << average << '\n';

    return EXIT_SUCCESS;
}
