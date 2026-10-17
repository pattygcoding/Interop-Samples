/// Interop sample: F# driving an SBCL (Common Lisp) script.
///
/// F# writes the numbers to the Lisp helper's standard input and reads the
/// average back from its standard output.
///
/// See README.md for build and run instructions.

open System
open System.Diagnostics
open System.Globalization

let script = IO.Path.Combine(__SOURCE_DIRECTORY__, "average.lisp")

let defaultNumbers = [ 10.0; 20.0; 30.0; 40.0; 50.0 ]

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

/// Run the Lisp helper and return the average it prints.
let calculateAverage (numbers: float list) =
    let startInfo = ProcessStartInfo()
    startInfo.FileName <- "sbcl"
    startInfo.ArgumentList.Add "--script"
    startInfo.ArgumentList.Add script
    startInfo.RedirectStandardInput <- true
    startInfo.RedirectStandardOutput <- true
    startInfo.RedirectStandardError <- true
    startInfo.UseShellExecute <- false

    use helper = Process.Start startInfo

    numbers
    |> List.map string
    |> String.concat " "
    |> helper.StandardInput.Write

    helper.StandardInput.Close()

    let stdout = helper.StandardOutput.ReadToEnd()
    let stderr = helper.StandardError.ReadToEnd()
    helper.WaitForExit()

    if helper.ExitCode <> 0 then
        let detail = stderr.Trim()

        let message =
            if String.IsNullOrWhiteSpace detail then
                sprintf "sbcl exited with code %d" helper.ExitCode
            else
                detail

        failwith message

    match tryParseNumber (stdout.Trim()) with
    | Some value -> value
    | None -> failwith (sprintf "unexpected output from the Lisp helper: %s" stdout)

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
