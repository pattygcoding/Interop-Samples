/**
 * Interop sample: TypeScript on Node.js driving a Python program.
 *
 * The child process reads a JSON array of numbers from stdin and writes the
 * average to stdout.
 *
 * See README.md for build and run instructions.
 */

import { spawn } from 'node:child_process';
import * as path from 'node:path';

// The compiled output lives in ./build, so the Python script (which sits next
// to this source file) is one level up.
const SCRIPT = path.resolve(__dirname, '..', 'average_calculator.py');

// Windows ships `python`; most Unix systems only provide `python3`.
const PYTHON = process.env.PYTHON ?? (process.platform === 'win32' ? 'python' : 'python3');

/**
 * Run the Python helper and resolve with the average it computes.
 */
function calculateAverage(numbers: number[], scriptPath: string = SCRIPT): Promise<number> {
  return new Promise((resolve, reject) => {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      reject(new Error('calculateAverage expects a non-empty array'));
      return;
    }

    const child = spawn(PYTHON, [scriptPath], { stdio: ['pipe', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk: Buffer) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk: Buffer) => {
      stderr += chunk;
    });

    child.on('error', (error: Error) => {
      reject(new Error(`failed to start ${PYTHON}: ${error.message}`));
    });

    child.on('close', (code: number | null) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `${PYTHON} exited with code ${code}`));
        return;
      }

      const value = Number.parseFloat(stdout.trim());
      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the Python program: ${JSON.stringify(stdout)}`));
        return;
      }
      resolve(value);
    });

    child.stdin.end(JSON.stringify(numbers));
  });
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const numbers = args.length > 0 ? args.map(Number) : [10, 20, 30, 40, 50];

  try {
    const average = await calculateAverage(numbers);
    console.log(`The average of ${numbers.length} value(s) is: ${average.toFixed(2)}`);
  } catch (error) {
    console.error(`error: ${(error as Error).message}`);
    process.exitCode = 1;
  }
}

if (require.main === module) {
  main();
}

export { calculateAverage };
