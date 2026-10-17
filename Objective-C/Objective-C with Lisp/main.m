/*
 * Interop sample: Objective-C driving an SBCL (Common Lisp) script.
 *
 * Objective-C builds the numbers into a command line, runs the Lisp helper
 * through a pipe, and reads the average it prints back.
 *
 * Built with GCC's Objective-C frontend and the GNU Objective-C runtime: the
 * helper class below is a plain root class, so nothing beyond libobjc is needed.
 *
 * See README.md for build and run instructions.
 */

#import <objc/objc.h>
#import <objc/runtime.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NUMBERS 64
#define COMMAND_SIZE 512

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

/* Report a failure and stop. */
static void fail(const char *message)
{
    fprintf(stderr, "error: %s\n", message);
    exit(1);
}

@interface AverageCalculator
{
    Class isa;
}

+ (id)alloc;

/* Run the Lisp helper on `values` and return the average it prints. */
- (double)averageForValues:(const double *)values count:(int)count;

@end

@implementation AverageCalculator

+ (id)alloc
{
    return class_createInstance(self, 0);
}

- (double)averageForValues:(const double *)values count:(int)count
{
    char command[COMMAND_SIZE] = "sbcl --script average_calculator.lisp";

    for (int i = 0; i < count; ++i) {
        char number[32] = {0};
        const size_t used = strlen(command);

        snprintf(number, sizeof(number), " %g", values[i]);

        if (used + strlen(number) + 1 > sizeof(command)) {
            fail("too many numbers for the command line");
        }

        strcat(command, number);
    }

    FILE *pipe = popen(command, "r");

    if (pipe == NULL) {
        fail("could not run the Lisp helper");
    }

    char line[64] = {0};
    char *got = fgets(line, sizeof(line), pipe);
    const int status = pclose(pipe);

    if (status != 0) {
        fail("the Lisp helper exited with a non-zero status");
    }

    if (got == NULL) {
        fail("the Lisp helper produced no output");
    }

    return strtod(line, NULL);
}

@end

int main(int argc, char *argv[])
{
    static const double fallback[] = {10, 20, 30, 40, 50};
    double values[MAX_NUMBERS];
    int count = 0;

    if (argc > 1) {
        for (int i = 1; i < argc && count < MAX_NUMBERS; ++i) {
            if (parse_number(argv[i], &values[count])) {
                ++count;
            } else {
                fprintf(stderr, "warning: skipping non-numeric argument '%s'\n", argv[i]);
            }
        }
    } else {
        for (size_t i = 0; i < sizeof(fallback) / sizeof(fallback[0]); ++i) {
            values[count++] = fallback[i];
        }
    }

    if (count == 0) {
        fail("no numbers to average");
    }

    id calculator = [AverageCalculator alloc];
    const double average = [calculator averageForValues:values count:count];

    printf("The average of %d value(s) is: %.2f\n", count, average);

    return 0;
}
