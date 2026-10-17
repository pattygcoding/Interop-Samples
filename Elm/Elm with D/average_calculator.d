// Interop sample: prints the arithmetic mean of the numbers given on the command
// line.
//
// Invoked by main.js; see README.md for build and run instructions.

import std.conv : ConvException, to;
import std.format : format;
import std.stdio : stderr, stdout, writeln;

int main(string[] args)
{
    if (args.length < 2)
    {
        stderr.writeln("error: no numbers supplied");
        return 1;
    }

    double total = 0.0;
    size_t count = 0;

    foreach (token; args[1 .. $])
    {
        try
        {
            total += token.to!double;
        }
        catch (ConvException)
        {
            stderr.writeln("error: '", token, "' is not a number");
            return 1;
        }

        ++count;
    }

    stdout.writeln(format("%.2f", total / count));

    return 0;
}
