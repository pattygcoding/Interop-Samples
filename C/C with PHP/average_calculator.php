<?php

/**
 * Interop sample: prints the arithmetic mean of the numbers given on the
 * command line.
 *
 * Invoked by main.c; see README.md for build and run instructions.
 */

declare(strict_types=1);

$arguments = array_slice($argv, 1);

if ($arguments === []) {
    fwrite(STDERR, "error: no numbers supplied\n");
    exit(1);
}

$numbers = [];

foreach ($arguments as $argument) {
    if (!is_numeric($argument)) {
        fwrite(STDERR, "error: '{$argument}' is not a number\n");
        exit(1);
    }

    $numbers[] = (float) $argument;
}

printf("%.2f\n", array_sum($numbers) / count($numbers));
