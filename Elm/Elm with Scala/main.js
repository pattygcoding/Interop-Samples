'use strict';

/**
 * Interop sample: Elm driving a Scala program.
 *
 * Elm cannot start processes, so this thin Node host loads the compiled Elm
 * program, answers its `calculate` port request by running the Scala helper, and
 * prints whatever the Elm program reports back. All of the presentation logic
 * lives in Elm; this file only moves bytes.
 *
 * See README.md for build and run instructions.
 */

const { spawn } = require('node:child_process');
const path = require('node:path');

const { Elm } = require('./elm.js');

const SCRIPT = path.join(__dirname, 'AverageCalculator.scala');

/**
 * Build the command that runs the Scala helper.
 *
 * On Windows `scala` is a `.cmd` shim, which cannot be spawned directly, so it is
 * routed through the command processor. Going through `cmd` rather than
 * `shell: true` matters: Node quotes each argument itself, and the sample path
 * contains a space.
 */
function scalaCommand(numbers) {
  const args = ['run', SCRIPT, '--', ...numbers.map(String)];

  return process.platform === 'win32'
    ? { command: 'cmd', args: ['/c', 'scala', ...args] }
    : { command: 'scala', args };
}

/**
 * Run the Scala helper on `numbers` and resolve with the average it prints.
 *
 * @param {number[]} numbers
 * @returns {Promise<number>}
 */
function runScala(numbers) {
  return new Promise((resolve, reject) => {
    const { command, args } = scalaCommand(numbers);
    const child = spawn(command, args, { stdio: ['ignore', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk) => {
      stderr += chunk;
    });

    child.on('error', (error) => {
      reject(new Error(`failed to start scala: ${error.message}`));
    });

    child.on('close', (code) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `scala exited with code ${code}`));
        return;
      }

      // Scala CLI prints build progress on stderr, so stdout holds only the
      // number the program printed.
      const value = Number.parseFloat(stdout.trim());
      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the Scala program: ${JSON.stringify(stdout)}`));
        return;
      }

      resolve(value);
    });
  });
}

const numbers = process.argv.length > 2 ? process.argv.slice(2).map(Number) : [10, 20, 30, 40, 50];

const app = Elm.Main.init({ flags: numbers });

app.ports.calculate.subscribe((values) => {
  runScala(values).then(
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
