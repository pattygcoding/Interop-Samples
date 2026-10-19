/*
 * Interop sample: prints the arithmetic mean of the numbers given on the
 * command line.
 *
 * Built with GCC's Objective-C frontend and the GNU Objective-C runtime. It
 * declares its own root class rather than using Foundation, so nothing beyond
 * libobjc is required.
 *
 * Invoked by main.ts; see README.md for build and run instructions.
 */

#import <objc/objc.h>
#import <objc/runtime.h>

#include <stdio.h>
#include <stdlib.h>

#define MAX_NUMBERS 64

@interface AverageCalculator
{
    Class isa;
}
+ (id)alloc;
- (double)meanOfValues:(const double *)values count:(int)count;
@end

@implementation AverageCalculator

+ (id)alloc
{
    return class_createInstance(self, 0);
}

- (double)meanOfValues:(const double *)values count:(int)count
{
    double total = 0.0;

    for (int i = 0; i < count; ++i) {
        total += values[i];
    }

    return count > 0 ? total / (double)count : 0.0;
}

@end

int main(int argc, char *argv[])
{
    if (argc < 2) {
        fprintf(stderr, "error: no numbers supplied\n");
        return 1;
    }

    double values[MAX_NUMBERS];
    int count = 0;

    for (int i = 1; i < argc && count < MAX_NUMBERS; ++i) {
        char *end = NULL;
        double value = strtod(argv[i], &end);

        if (end == argv[i] || *end != '\0') {
            fprintf(stderr, "error: '%s' is not a number\n", argv[i]);
            return 1;
        }

        values[count++] = value;
    }

    id calculator = [AverageCalculator alloc];

    printf("%.2f\n", [calculator meanOfValues:values count:count]);

    return 0;
}
