# PHP with Dart

PHP passes the numbers as command-line arguments to a Dart program and reads the
average it prints back from stdout.

| | |
|---|---|
| **Host language** | PHP |
| **Guest language** | Dart |
| **Bridge** | Child process + argv/stdout |
| **Files** | `main.php`, `average_calculator.dart` |

## Prerequisites

- **PHP** 8.0 or newer (`php`)
- The **Dart SDK** 3.0 or newer (`dart`) on your `PATH`

## Build & run

```bash
php main.php                 # uses the built-in default data set
php main.php 1 2 3 4
php main.php -5 5 10
```

You can also exercise the Dart side on its own:

```bash
dart average_calculator.dart 10 20 30     # -> 20.00
```

## Expected output

```text
$ php main.php
The average of 5 value(s) is: 30.00

$ php main.php 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.php` builds the command line with `escapeshellarg` around every argument
and captures the result with `exec`, which reports the exit status alongside the
output:

```php
exec($command, $output, $status);

if ($status !== 0) {
    throw new RuntimeException($detail !== '' ? $detail : "dart exited with status {$status}");
}
```

The script declares `strict_types=1` and uses typed signatures throughout, and
it skips non-numeric arguments with a warning rather than failing outright.

`average_calculator.dart` parses each argument with `double.tryParse`, folds the
values into a sum and prints the mean with `toStringAsFixed(2)`. Invalid input is
reported on stderr with exit status 1.
