/**
 * Interop sample: Haxe driving the Dart Sass compiler.
 *
 * This file is compiled to Neko bytecode, so the host program runs on the Neko
 * virtual machine. The SCSS module in `average_calculator.scss` computes the
 * mean of a list of numbers: Haxe configures it with the numbers under test,
 * compiles it with `sass`, and reads the result back out of the generated CSS.
 *
 * See README.md for build and run instructions.
 */
class Main {
	static inline var MODULE = "average_calculator.scss";
	static var DEFAULT_NUMBERS = [10.0, 20.0, 30.0, 40.0, 50.0];

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

	/** Pick a directory to build the generated Sass in. */
	static function scratchDirectory():String {
		var base = Sys.getEnv("TEMP");

		if (base == null || base == "") {
			base = Sys.getEnv("TMPDIR");
		}

		if (base == null || base == "") {
			base = Sys.getCwd();
		}

		return slashes(base) + "/scss-average-" + Std.string(Std.random(1000000));
	}

	/** Sass wants forward slashes, even on Windows. */
	static inline function slashes(path:String):String {
		return StringTools.replace(path, "\\", "/");
	}

	/**
	 * Compile the SCSS module configured with `numbers` and return the mean.
	 *
	 * `Sys.command` runs the line through the platform's command processor,
	 * which is what lets it reach the `sass` command: on Windows that is a
	 * `.cmd` shim, and Neko's `sys.io.Process` cannot start one directly.
	 */
	static function calculateAverage(numbers:Array<Float>):Float {
		if (numbers.length == 0) {
			throw "calculateAverage expects a non-empty array";
		}

		var directory = scratchDirectory();
		var entry = directory + "/entry.scss";
		var result = directory + "/result.css";

		sys.FileSystem.createDirectory(directory);

		var average:Float = 0.0;
		var failure:Null<String> = null;

		try {
			var values = numbers.map(function (number) return Std.string(number)).join(", ");

			sys.io.File.saveContent(entry, '@use "average_calculator" with ($$numbers: ($values));\n');

			var command = 'sass --no-source-map --load-path "${slashes(Sys.getCwd())}" "$entry" "$result"';
			var exitCode = Sys.command(command);

			if (exitCode != 0) {
				throw 'sass exited with code $exitCode';
			}

			var css = sys.io.File.getContent(result);
			var pattern = new EReg("--average:\\s*(-?[0-9.]+)", "");

			if (!pattern.match(css)) {
				throw 'could not find --average in the compiled CSS:\n$css';
			}

			average = Std.parseFloat(pattern.matched(1));
		} catch (error:Dynamic) {
			failure = Std.string(error);
		}

		// Haxe has no `finally`, so the scratch files are removed by hand.
		removeIfPresent(entry);
		removeIfPresent(result);

		if (sys.FileSystem.exists(directory)) {
			sys.FileSystem.deleteDirectory(directory);
		}

		if (failure != null) {
			throw failure;
		}

		return average;
	}

	/** Delete a file if it is there. */
	static function removeIfPresent(path:String):Void {
		if (sys.FileSystem.exists(path)) {
			sys.FileSystem.deleteFile(path);
		}
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
