'use strict';

/**
 * Interop sample: Elm driving a Prolog program.
 *
 * Elm cannot start processes, so this thin Node host loads the compiled Elm
 * program, answers its `calculate` port request by running SWI-Prolog, and
 * prints whatever the Elm program reports back. All of the presentation logic
 * lives in Elm; this file only moves bytes.
 *
 * See README.md for build and run instructions.
 */

const { spawn } = require('node:child_process');
const path = require('node:path');

const { Elm } = require('./elm.js');

const SCRIPT = path.join(__dirname, 'average.pl');

/**
 * Run the Prolog helper on `numbers` and resolve with the average it prints.
 *
 * @param {number[]} numbers
 * @returns {Promise<number>}
 */
function runProlog(numbers) {
  return new Promise((resolve, reject) => {
    const child = spawn(
      'swipl',
      ['-q', '-f', SCRIPT, '-g', 'main', '--', ...numbers.map(String)],
      { stdio: ['ignore', 'pipe', 'pipe'] }
    );

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      reject(new Error(`failed to start swipl: ${error.message}`));
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `swipl exited with code ${code}`));
        return;
      }

      const value = Number.parseFloat(stdout.trim());
      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the Prolog helper: ${JSON.stringify(stdout)}`));
        return;
      }

      resolve(value);
    });
  });
}

const numbers = process.argv.length > 2 ? process.argv.slice(2).map(Number) : [10, 20, 30, 40, 50];

const app = Elm.Main.init({ flags: numbers });

app.ports.calculate.subscribe((values) => {
  runProlog(values).then(
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
