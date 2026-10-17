/*
 * Interop sample: C driving a hand-written x86 assembly routine.
 *
 * All of the arithmetic lives in `calculate_average.asm`; this translation
 * unit only supplies the numbers and prints the result. Numbers may be passed
 * on the command line, otherwise a small default data set is used.
 *
 * See README.md for build and run instructions.
 */

#include <stdio.h>
#include <stdlib.h>

#define MAX_NUMBERS 256

/* Implemented in calculate_average.asm. */
extern double calculate_average(const int *numbers, int count);

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

    double average = calculate_average(numbers, count);
    printf("The average of %d value(s) is: %.2f\n", count, average);

    return EXIT_SUCCESS;
}

