/*
 * Interop sample: prints the arithmetic mean of the numbers given on the command
 * line.
 *
 * Invoked by main.cpp; see README.md for build and run instructions.
 */

#include <stdio.h>
#include <stdlib.h>

/* Parse one token, returning 1 when it is a complete number. */
static int parse_number(const char *text, double *value)
{
    char *end = NULL;
    const double parsed = strtod(text, &end);

    if (end == text || *end != '\0') {
        return 0;
    }

    *value = parsed;
    return 1;
}

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "error: no numbers supplied\n");
        return EXIT_FAILURE;
    }

    double total = 0.0;
    int count = 0;

    for (int i = 1; i < argc; ++i) {
        double value;

        if (!parse_number(argv[i], &value)) {
            fprintf(stderr, "error: '%s' is not a number\n", argv[i]);
            return EXIT_FAILURE;
        }

        total += value;
        ++count;
    }

    printf("%.2f\n", total / (double)count);

    return EXIT_SUCCESS;
}
