/**
 * Interop sample: TypeScript on Node.js driving a compiled Objective-C program.
 *
 * Node passes the numbers as command-line arguments to the Objective-C helper
 * and reads the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */

import { spawn } from 'node:child_process';
import * as path from 'node:path';

// The compiled output lives in ./build, so the helper (which sits next to this
// source file) is one level up.
const EXECUTABLE = path.resolve(
  __dirname,
  '..',
  process.platform === 'win32' ? 'average_calculator.exe' : 'average_calculator'
);

/**
 * Run the Objective-C helper and resolve with the average it computes.
 */
function calculateAverage(numbers: number[], executable: string = EXECUTABLE): Promise<number> {
  return new Promise((resolve, reject) => {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      reject(new Error('calculateAverage expects a non-empty array'));
      return;
    }

    const child = spawn(executable, numbers.map(String), { stdio: ['ignore', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk: Buffer) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk: Buffer) => {
      stderr += chunk;
    });

    child.on('error', (error: Error) => {
      reject(new Error(`failed to start the Objective-C helper: ${error.message}`));
    });

    child.on('close', (code: number | null) => {
      if (code !== 0) {
        reject(new Error(stderr.trim() || `the Objective-C helper exited with code ${code}`));
        return;
      }

      const value = Number.parseFloat(stdout.trim());
      if (Number.isNaN(value)) {
        reject(new Error(`unexpected output from the Objective-C helper: ${JSON.stringify(stdout)}`));
        return;
      }
      resolve(value);
    });
  });
}

/**
 * Convert command-line tokens to numbers, skipping anything invalid.
 *
 * Callers pass the tokens through unchanged: converting them with `Number()`
 * first would turn bad input into `NaN`, which the helper would then happily
 * average as a real value.
 */
function parseNumbers(tokens: string[]): number[] {
  const numbers: number[] = [];

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

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  const numbers = args.length > 0 ? parseNumbers(args) : [10, 20, 30, 40, 50];

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

export { calculateAverage, parseNumbers };
