'use strict';

/**
 * Interop sample: Elm driving a compiled Swift program.
 *
 * Elm cannot start processes, so this thin Node host loads the compiled Elm
 * program, answers its `calculate` port request by running the Swift helper, and
 * prints whatever the Elm program reports back. All of the presentation logic
 * lives in Elm; this file only moves bytes.
 *
 * See README.md for build and run instructions.
 */

const { spawn } = require('node:child_process');
const path = require('node:path');

const { Elm } = require('./elm.js');

const EXECUTABLE = path.join(
  __dirname,
  process.platform === 'win32' ? 'average_calculator.exe' : 'average_calculator'
);

/**
 * Run the Swift helper on `numbers` and resolve with the average it prints.
 *
 * @param {number[]} numbers
 * @returns {Promise<number>}
 */
function runSwift(numbers) {
  return new Promise((resolve, reject) => {
    const child = spawn(EXECUTABLE, numbers.map(String), { stdio: ['ignore', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      reject(new Error(`failed to start the Swift helper: ${error.message}`));
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `the Swift helper exited with code ${code}`));
        return;
      }

      const value = Number.parseFloat(stdout.trim());
      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the Swift helper: ${JSON.stringify(stdout)}`));
        return;
      }

      resolve(value);
    });
  });
}

const numbers = process.argv.length > 2 ? process.argv.slice(2).map(Number) : [10, 20, 30, 40, 50];

const app = Elm.Main.init({ flags: numbers });

app.ports.calculate.subscribe((values) => {
  runSwift(values).then(
    (average) => app.ports.calculated.send(average),
    (error) => {
      console.error(`error: ${error.message}`);
      process.exitCode = 1;
    }
  );
});

app.ports.report.subscribe((line) => {
  console.log(line);
});
