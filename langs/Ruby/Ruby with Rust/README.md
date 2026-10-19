# Ruby with Rust

Ruby writes the numbers to a compiled Rust program's standard input and reads the
average back from its standard output.

| | |
|---|---|
| **Host language** | Ruby |
| **Guest language** | Rust |
| **Bridge** | Child process + stdin/stdout |
| **Files** | `main.rb`, `average_calculator.rs` |

## Prerequisites

- **Ruby** 2.7 or newer (`ruby`)
- **rustc** (any recent stable toolchain) on your `PATH`

## Build & run

Compile the helper first (the Ruby script expects the binary next to it):

```bash
rustc -O average_calculator.rs -o average_calculator
ruby main.rb                 # uses the built-in default data set
ruby main.rb 1 2 3 4
ruby main.rb -5 5 10
```

On Windows `rustc` appends `.exe` automatically; `main.rb` detects the platform
and looks for the right name.

You can also exercise the Rust side on its own:

```bash
echo "10 20 30" | ./average_calculator
```

## Expected output

```text
$ ruby main.rb
The average of 5 value(s) is: 30.00

$ ruby main.rb 1 2 3 4
The average of 4 value(s) is: 2.50
```

## How it works

`main.rb` pipes the numbers in and captures the result with `Open3`:

```ruby
stdout, status = Open3.capture2([executable.to_s, executable.to_s], stdin_data: numbers.join(' '))
```

The two-element array form (`[command, argv0]`) makes Ruby execute the binary
directly instead of handing a command line to a shell — which matters here,
because the sample directory name contains a space.

`average_calculator.rs` reads all of stdin, parses the tokens with
`str::parse::<f64>`, and prints the mean with 15 significant digits. Malformed
input and empty input both exit with status 1 after a message on stderr.
