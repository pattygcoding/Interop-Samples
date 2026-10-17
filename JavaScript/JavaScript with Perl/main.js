'use strict';

/**
 * Interop sample: Node.js driving a Perl script.
 *
 * Node passes the numbers as command-line arguments to the Perl helper and reads
 * the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */

const { spawn } = require('node:child_process');
const path = require('node:path');

const SCRIPT = path.join(__dirname, 'average_calculator.pl');

/**
 * Run the Perl helper on `numbers` and resolve with the average it prints.
 *
 * @param {number[]} numbers
 * @returns {Promise<number>}
 */
function calculateAverage(numbers) {
  return new Promise((resolve, reject) => {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      reject(new Error('calculateAverage expects a non-empty array'));
      return;
    }

    const child = spawn('perl', [SCRIPT, ...numbers.map(String)], { stdio: ['ignore', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });

    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      reject(new Error(`failed to start perl: ${error.message}`));
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `perl exited with code ${code}`));
        return;
      }

      const value = Number.parseFloat(stdout.trim());

      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the Perl helper: ${JSON.stringify(stdout)}`));
        return;
      }

      resolve(value);
    });
  });
}

/** Convert command-line tokens to numbers, skipping anything invalid. */
function parseNumbers(tokens) {
  const numbers = [];

  for (const token of tokens) {
    const value = Number(token);

    if (Number.isNaN(value)) {
      console.error(`warning: skipping non-numeric argument '${token}'`);
    } else {
      numbers.push(value);
    }
  }

  return numbers;
}

async function main() {
  const args = process.argv.slice(2);
  const numbers = args.length > 0 ? parseNumbers(args) : [10, 20, 30, 40, 50];

  if (numbers.length === 0) {
    console.error('error: no numbers to average');
    process.exitCode = 1;
    return;
  }

  try {
    const average = await calculateAverage(numbers);
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
