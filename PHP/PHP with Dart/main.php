<?php

/**
 * Interop sample: PHP driving a Dart program.
 *
 * PHP passes the numbers as command-line arguments to `average_calculator.dart`
 * and reads the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */

declare(strict_types=1);

const DEFAULT_NUMBERS = [10, 20, 30, 40, 50];

/**
 * Run the Dart helper and return the average it prints.
 *
 * @param list<float|int> $numbers
 */
function calculateAverage(array $numbers): float
{
    if ($numbers === []) {
        throw new InvalidArgumentException('calculateAverage expects a non-empty array');
    }

    $command = escapeshellarg('dart') . ' average_calculator.dart';

    foreach ($numbers as $number) {
        $command .= ' ' . escapeshellarg((string) $number);
    }

    $output = [];
    $status = 0;
    exec($command, $output, $status);

    if ($status !== 0) {
        $detail = trim(implode("\n", $output));

        throw new RuntimeException($detail !== '' ? $detail : "dart exited with status {$status}");
    }

    $average = (float) trim(implode("\n", $output));

    return $average;
}

/**
 * Convert command-line tokens to floats, skipping anything invalid.
 *
 * @param list<string> $tokens
 * @return list<float>
 */
function parseNumbers(array $tokens): array
{
    $numbers = [];

    foreach ($tokens as $token) {
        if (is_numeric($token)) {
            $numbers[] = (float) $token;
        } else {
            fwrite(STDERR, "warning: skipping non-numeric argument '{$token}'\n");
        }
    }

    return $numbers;
}

$arguments = array_slice($argv, 1);
$numbers = $arguments === [] ? DEFAULT_NUMBERS : parseNumbers($arguments);

if ($numbers === []) {
    fwrite(STDERR, "error: no numbers to average\n");
    exit(1);
}

try {
    $average = calculateAverage($numbers);
} catch (Throwable $error) {
    fwrite(STDERR, "error: {$error->getMessage()}\n");
    exit(1);
}

printf("The average of %d value(s) is: %.2f\n", count($numbers), $average);
