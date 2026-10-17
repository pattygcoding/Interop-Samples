'use strict';

/**
 * Interop sample: reads whitespace-separated numbers from standard input and
 * writes the arithmetic mean to standard output.
 *
 * Invoked by main.adb; see README.md for build and run instructions.
 */

let input = '';

process.stdin.setEncoding('utf8');

process.stdin.on('data', (chunk) => {
  input += chunk;
});

process.stdin.on('end', () => {
  const tokens = input.split(/\s+/).filter((token) => token.length > 0);

  if (tokens.length === 0) {
    console.error('error: no numbers on stdin');
    process.exit(1);
  }

  let total = 0;

  for (const token of tokens) {
    const value = Number.parseFloat(token);

    if (Number.isNaN(value)) {
      console.error(`error: '${token}' is not a number`);
      process.exit(1);
    }

    total += value;
  }

  console.log((total / tokens.length).toFixed(2));
});
