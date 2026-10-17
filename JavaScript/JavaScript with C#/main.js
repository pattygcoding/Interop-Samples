'use strict';

/**
 * Interop sample: Node.js driving a C# program.
 *
 * The child process reads a JSON array of numbers from stdin and writes the
 * average to stdout. Using stdin (rather than a command-line argument) keeps
 * large inputs and shell quoting out of the picture.
 *
 * See README.md for build and run instructions.
 */

const { spawn } = require('node:child_process');
const path = require('node:path');

// The C# project lives next to this script; resolve it independently of the
// current working directory.
const PROJECT = __dirname;

/**
 * Run the C# helper and resolve with the average it computes.
 *
 * @param {number[]} numbers values to average
 * @param {string} [projectPath] path to the C# project
 * @returns {Promise<number>}
 */
function calculateAverage(numbers, projectPath = PROJECT) {
  return new Promise((resolve, reject) => {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      reject(new Error('calculateAverage expects a non-empty array'));
      return;
    }

    const child = spawn('dotnet', ['run', '--project', projectPath, '-v', 'quiet', '--nologo'], {
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      reject(new Error(`failed to start dotnet: ${error.message}`));
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `dotnet exited with code ${code}`));
        return;
      }

      const value = Number.parseFloat(stdout.trim());
      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the C# program: ${JSON.stringify(stdout)}`));
        return;
      }
      resolve(value);
    });

    child.stdin.end(JSON.stringify(numbers));
  });
}

async function main() {
  const numbers = process.argv.length > 2
    ? process.argv.slice(2).map(Number)
    : [10, 20, 30, 40, 50];

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

