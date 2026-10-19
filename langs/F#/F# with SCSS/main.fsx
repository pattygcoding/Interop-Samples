/// Interop sample: F# driving the Dart Sass compiler.
///
/// The SCSS module in `average_calculator.scss` computes the mean of a list of
/// numbers. F# configures it with the numbers under test, compiles it with
/// `sass`, and reads the result back out of the generated CSS.
///
/// See README.md for build and run instructions.

open System
open System.Diagnostics
open System.Globalization
open System.IO
open System.Text.RegularExpressions

let moduleDirectory = __SOURCE_DIRECTORY__

let defaultNumbers = [ 10.0; 20.0; 30.0; 40.0; 50.0 ]

/// Build the command that runs Dart Sass.
///
/// On Windows `sass` installs as a .cmd shim, which CreateProcess cannot start,
/// so the command goes through the command processor instead.
let sassInvocation (arguments: string list) =
    if OperatingSystem.IsWindows() then
        "cmd", [ "/c"; "sass" ] @ arguments
    else
        "sass", arguments

/// Compile the SCSS module configured with `numbers` and return the mean.
let calculateAverage (numbers: float list) =
    if List.isEmpty numbers then
        invalidArg "numbers" "calculateAverage expects a non-empty list"

    let directory = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString("N"))
    Directory.CreateDirectory directory |> ignore

    let entry = Path.Combine(directory, "entry.scss")
    let result = Path.Combine(directory, "result.css")

    try
        let values =
            numbers
            |> List.map (fun value -> value.ToString(CultureInfo.InvariantCulture))
            |> String.concat ", "

        File.WriteAllText(entry, sprintf "@use \"average_calculator\" with ($numbers: (%s));\n" values)

        let command, arguments =
            sassInvocation
                [ "--no-source-map"
                  "--load-path"
                  moduleDirectory
                  entry
                  result ]

        let startInfo = ProcessStartInfo command
        startInfo.UseShellExecute <- false
        startInfo.RedirectStandardOutput <- true
        startInfo.RedirectStandardError <- true

        for argument in arguments do
            startInfo.ArgumentList.Add argument

        use sass = Process.Start startInfo
        let errors = sass.StandardError.ReadToEnd()
        sass.WaitForExit()

        if sass.ExitCode <> 0 then
            let detail = errors.Trim()

            failwith (
                if String.IsNullOrWhiteSpace detail then
                    sprintf "sass exited with code %d" sass.ExitCode
                else
                    detail
            )

        let css = File.ReadAllText result
        let matched = Regex.Match(css, @"--average:\s*(-?\d+(?:\.\d+)?)")

        if not matched.Success then
            failwith (sprintf "could not find --average in the compiled CSS:%s%s" Environment.NewLine css)

        Double.Parse(matched.Groups[1].Value, CultureInfo.InvariantCulture)
    finally
        for path in [ entry; result ] do
            if File.Exists path then
                File.Delete path

        if Directory.Exists directory then
            Directory.Delete directory

/// Parse a token using the invariant culture so the decimal separator does not
/// depend on the machine's locale.
let tryParseNumber (token: string) =
    match Double.TryParse(token, NumberStyles.Float, CultureInfo.InvariantCulture) with
    | true, value -> Some value
    | _ -> None

/// Convert command-line tokens to floats, skipping anything invalid.
let parseNumbers (tokens: string array) =
    [ for token in tokens do
          match tryParseNumber token with
          | Some value -> yield value
          | None -> eprintfn "warning: skipping non-numeric argument '%s'" token ]

let run (argv: string array) =
    let numbers = if argv.Length > 0 then parseNumbers argv else defaultNumbers

    if List.isEmpty numbers then
        eprintfn "error: no numbers to average"
        1
    else

    try
        let average = calculateAverage numbers
        printfn "The average of %d value(s) is: %.2f" numbers.Length average
        0
    with ex ->
        eprintfn "error: %s" ex.Message
        1

exit (run (fsi.CommandLineArgs |> Array.skip 1))
