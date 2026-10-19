'use strict';

/**
 * Interop sample: Node.js driving the SQLite command-line shell.
 *
 * Node loads the numbers into an in-memory SQLite database and runs the query in
 * `average_calculator.sql`, so the mean is computed in SQL.
 *
 * See README.md for build and run instructions.
 */

const { spawn } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');

const QUERY_FILE = path.join(__dirname, 'average_calculator.sql');

/**
 * Run a SQL script through the sqlite3 shell and resolve with its output.
 *
 * @param {string} statement
 * @returns {Promise<string>}
 */
function sqlite(statement) {
  return new Promise((resolve, reject) => {
    const child = spawn('sqlite3', ['-batch', ':memory:'], { stdio: ['pipe', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      reject(new Error(`failed to start sqlite3: ${error.message}`));
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `sqlite3 exited with code ${code}`));
        return;
      }

      resolve(stdout);
    });

    // The script goes in on stdin, which avoids the shell treating a leading
    // "--" comment as a command-line option.
    child.stdin.end(statement);
  });
}

/**
 * Load `numbers` into SQLite and return the average the query file computes.
 *
 * @param {number[]} numbers
 * @returns {Promise<number>}
 */
async function calculateAverage(numbers) {
  if (!Array.isArray(numbers) || numbers.length === 0) {
    throw new Error('calculateAverage expects a non-empty array');
  }

  const values = numbers.map((value) => `(${value})`).join(', ');
  const query = fs.readFileSync(QUERY_FILE, 'utf8');

  const script = [
    'CREATE TABLE numbers (value REAL);',
    `INSERT INTO numbers (value) VALUES ${values};`,
    query,
  ].join('\n');

  const output = await sqlite(script);
  const average = Number.parseFloat(output.trim());

  if (Number.isNaN(average)) {
    throw new Error(`unexpected output from sqlite3: ${JSON.stringify(output)}`);
  }

  return average;
}

async function main() {
  const args = process.argv.slice(2);
  const numbers = args.length > 0 ? args.map(Number) : [10, 20, 30, 40, 50];

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
