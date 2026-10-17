// Interop sample: reads whitespace-separated numbers from one file and writes
// their arithmetic mean to another.
//
// Invoked by main.ml; see README.md for build and run instructions.
package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

func fail(format string, arguments ...any) {
	fmt.Fprintf(os.Stderr, "error: "+format+"\n", arguments...)
	os.Exit(1)
}

func main() {
	if len(os.Args) < 3 {
		fail("usage: average_calculator <input-file> <output-file>")
	}

	raw, err := os.ReadFile(os.Args[1])
	if err != nil {
		fail("cannot read %s: %v", os.Args[1], err)
	}

	tokens := strings.Fields(string(raw))

	if len(tokens) == 0 {
		fail("no numbers found in %s", os.Args[1])
	}

	total := 0.0

	for _, token := range tokens {
		value, err := strconv.ParseFloat(token, 64)

		if err != nil {
			fail("'%s' is not a number", token)
		}

		total += value
	}

	average := total / float64(len(tokens))

	if err := os.WriteFile(os.Args[2], []byte(fmt.Sprintf("%.2f\n", average)), 0o644); err != nil {
		fail("cannot write %s: %v", os.Args[2], err)
	}
}
