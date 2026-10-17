/**
 * Interop sample: Haxe driving a Groovy script.
 *
 * This file is compiled to Neko bytecode, so the host program runs on the Neko
 * virtual machine. It passes the numbers as command-line arguments to
 * `average_calculator.groovy` and reads the average it prints back from stdout.
 *
 * See README.md for build and run instructions.
 */
class Main {
	static inline var SCRIPT = "average_calculator.groovy";
	static var DEFAULT_NUMBERS = [10.0, 20.0, 30.0, 40.0, 50.0];

	/**
	 * Build the classpath for the Groovy interpreter.
	 *
	 * On Windows `groovy` is a `.cmd` shim, which Neko's `sys.io.Process` cannot
	 * spawn, so the interpreter is started through `java` instead.
	 */
	static function classpath():String {
		var separator = Sys.systemName() == "Windows" ? ";" : ":";
		var home = Sys.getEnv("GROOVY_HOME");

		if (home == null || home == "") {
			home = "/usr/share/groovy";
		}

		return home + "/lib/*";
	}

	/** Convert command-line tokens to floats, skipping anything invalid. */
	static function parseNumbers(tokens:Array<String>):Array<Float> {
		var numbers:Array<Float> = [];

		for (token in tokens) {
			var value = Std.parseFloat(token);

			if (Math.isNaN(value)) {
				Sys.stderr().writeString('warning: skipping non-numeric argument \'$token\'\n');
			} else {
				numbers.push(value);
			}
		}

		return numbers;
	}

	/** Run the Groovy helper and return the average it prints. */
	static function calculateAverage(numbers:Array<Float>):Float {
		var arguments = ["-cp", classpath(), "groovy.ui.GroovyMain", SCRIPT];

		for (number in numbers) {
			arguments.push(Std.string(number));
		}

		var process = new sys.io.Process("java", arguments);
		var output = process.stdout.readAll().toString();
		var errors = process.stderr.readAll().toString();
		var exitCode = process.exitCode();

		if (exitCode != 0) {
			var detail = StringTools.trim(errors);
			throw(detail.length > 0 ? detail : 'groovy exited with code $exitCode');
		}

		var text = StringTools.trim(output);
		var value = Std.parseFloat(text);

		if (Math.isNaN(value)) {
			throw 'unexpected output from the Groovy script: $output';
		}

		return value;
	}

	/** Render a float with a fixed number of decimals. */
	static function toFixed(value:Float, decimals:Int):String {
		var factor = Std.int(Math.pow(10, decimals));
		var scaled = Math.round(value * factor);
		var sign = scaled < 0 ? "-" : "";
		var magnitude = Std.int(Math.abs(scaled));

		return sign + Std.int(magnitude / factor) + "." + StringTools.lpad(Std.string(magnitude % factor), "0", decimals);
	}

	static function main() {
		var args = Sys.args();
		var numbers = args.length > 0 ? parseNumbers(args) : DEFAULT_NUMBERS;

		if (numbers.length == 0) {
			Sys.stderr().writeString("error: no numbers to average\n");
			Sys.exit(1);
		}

		try {
			var average = calculateAverage(numbers);
			Sys.println('The average of ${numbers.length} value(s) is: ${toFixed(average, 2)}');
		} catch (message:String) {
			Sys.stderr().writeString('error: $message\n');
			Sys.exit(1);
		}
	}
}
