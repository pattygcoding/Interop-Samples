/*
 * Interop sample: C driving a PHP program.
 *
 * C passes the numbers as command-line arguments to `average_calculator.php` and
 * reads the average it prints back through a pipe.
 *
 * See README.md for build and run instructions.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NUMBERS  64
#define COMMAND_SIZE 512

/* Parse the command line into `numbers`, skipping anything that is not a
 * valid base-10 integer. Returns the number of values collected. */
static int parse_numbers(int argc, char *argv[], int *numbers, int max)
{
    int count = 0;

    for (int i = 1; i < argc && count < max; ++i) {
        char *end = NULL;
        long value = strtol(argv[i], &end, 10);

        if (end == argv[i] || *end != '\0') {
            fprintf(stderr, "warning: skipping non-integer argument '%s'\n", argv[i]);
            continue;
        }
        numbers[count++] = (int)value;
    }

    return count;
}

/* Build the `php average_calculator.php <numbers...>` command line. */
static int build_command(char *command, size_t size, const int *numbers, int count)
{
    size_t used = (size_t)snprintf(command, size, "php average_calculator.php");

    for (int i = 0; i < count; ++i) {
        int written = snprintf(command + used, size - used, " %d", numbers[i]);

        if (written < 0 || (size_t)written >= size - used) {
            return -1;
        }
        used += (size_t)written;
    }

    return 0;
}

int main(int argc, char *argv[])
{
    static const int defaults[] = {10, 20, 30, 40, 50};
    int numbers[MAX_NUMBERS];
    int count = 0;

    if (argc > 1) {
        count = parse_numbers(argc, argv, numbers, MAX_NUMBERS);
    } else {
        for (size_t i = 0; i < sizeof(defaults) / sizeof(defaults[0]); ++i) {
            numbers[count++] = defaults[i];
        }
    }

    if (count == 0) {
        fprintf(stderr, "error: no integers to average\n");
        return EXIT_FAILURE;
    }

    char command[COMMAND_SIZE];

    if (build_command(command, sizeof(command), numbers, count) != 0) {
        fprintf(stderr, "error: too many numbers for the command line\n");
        return EXIT_FAILURE;
    }

    FILE *pipe = popen(command, "r");
    if (pipe == NULL) {
        fprintf(stderr, "error: could not run '%s'\n", command);
        return EXIT_FAILURE;
    }

    char line[64] = {0};
    char *got = fgets(line, sizeof(line), pipe);
    int status = pclose(pipe);

    if (status != 0) {
        fprintf(stderr, "error: the PHP helper exited with status %d\n", status);
        return EXIT_FAILURE;
    }

    if (got == NULL) {
        fprintf(stderr, "error: the PHP helper produced no output\n");
        return EXIT_FAILURE;
    }

    line[strcspn(line, "\r\n")] = '\0';

    printf("The average of %d value(s) is: %.2f\n", count, strtod(line, NULL));

    return EXIT_SUCCESS;
}
