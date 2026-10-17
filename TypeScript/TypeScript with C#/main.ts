/**
 * Interop sample: TypeScript on Node.js driving a C# program.
 *
 * The .NET console app takes the numbers as command-line arguments and writes the
 * average to stdout.
 *
 * See README.md for build and run instructions.
 */

import { spawn } from 'node:child_process';
import * as path from 'node:path';

// The compiled output lives in ./build, so the C# project (which sits next to
// this source file) is one level up.
const PROJECT = path.resolve(__dirname, '..');

/**
 * Run the C# helper and resolve with the average it computes.
 */
function calculateAverage(numbers: number[], projectPath: string = PROJECT): Promise<number> {
  return new Promise((resolve, reject) => {
    if (!Array.isArray(numbers) || numbers.length === 0) {
      reject(new Error('calculateAverage expects a non-empty array'));
      return;
    }

    const child = spawn(
      'dotnet',
      ['run', '--project', projectPath, '-v', 'quiet', '--', ...numbers.map(String)],
      { stdio: ['ignore', 'pipe', 'pipe'] }
    );

    let stdout = '';
    let stderr = '';

    child.stdout.on('data', (chunk: Buffer) => {
      stdout += chunk;
    });
    child.stderr.on('data', (chunk: Buffer) => {
      stderr += chunk;
    });

    child.on('error', (error: Error) => {
      reject(new Error(`failed to start dotnet: ${error.message}`));
    });

    child.on('close', (code: number | null) => {
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
