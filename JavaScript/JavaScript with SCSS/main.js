'use strict';

/**
 * Interop sample: Node.js driving the Dart Sass compiler.
 *
 * The SCSS module in `average_calculator.scss` computes the mean of a list of
 * numbers. Node configures it with the numbers under test, compiles it, and
 * reads the result back out of the generated CSS custom property.
 *
 * See README.md for build and run instructions.
 */

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const sass = require('sass');

const MODULE_DIRECTORY = __dirname;

/**
 * Compile the SCSS module configured with `numbers` and return the average it
 * computes.
 *
 * @param {number[]} numbers values to average
 * @returns {number}
 */
function calculateAverage(numbers) {
  if (!Array.isArray(numbers) || numbers.length === 0) {
    throw new Error('calculateAverage expects a non-empty array');
  }

  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'scss-average-'));
  const entry = path.join(directory, 'entry.scss');

  try {
    // Configure the module with the numbers, then compile it.
    fs.writeFileSync(entry, `@use "average_calculator" with ($numbers: (${numbers.join(', ')}));\n`);

    const css = sass.compile(entry, { loadPaths: [MODULE_DIRECTORY] }).css;
    const match = /--average:\s*(-?\d+(?:\.\d+)?)/.exec(css);

    if (!match) {
      throw new Error(`could not find --average in the compiled CSS:\n${css}`);
    }

    return Number.parseFloat(match[1]);
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
}

function main() {
  const args = process.argv.slice(2);
  const numbers = args.length > 0 ? args.map(Number) : [10, 20, 30, 40, 50];

  try {
    const average = calculateAverage(numbers);
    console.log(`The average of ${numbers.length} value(s) is: ${average.toFixed(2)}`);
  } catch (error) {
    console.error(`error: ${error.message}`);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  main();
}

module.exports = { calculateAverage };
