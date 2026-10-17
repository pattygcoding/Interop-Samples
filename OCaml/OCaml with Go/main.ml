(* Interop sample: OCaml driving a compiled Go program.
 *
 * OCaml writes the numbers to a temporary file, runs the Go helper with that
 * file as input, and reads the average back from the file the helper writes.
 *
 * See README.md for build and run instructions. *)

let default_numbers = [ 10.0; 20.0; 30.0; 40.0; 50.0 ]

let executable =
  if Sys.win32 then "average_calculator.exe" else "average_calculator"

(* Convert command-line tokens to floats, skipping anything invalid. *)
let parse_numbers tokens =
  List.filter_map
    (fun token ->
      match float_of_string_opt token with
      | Some value -> Some value
      | None ->
          Printf.eprintf "warning: skipping non-numeric argument '%s'\n" token;
          None)
    tokens

(* Run the Go helper on [numbers] and return the average it writes. *)
let calculate_average numbers =
  let input = Filename.temp_file "numbers" ".txt" in
  let output = Filename.temp_file "average" ".txt" in

  Fun.protect
    ~finally:(fun () ->
      (try Sys.remove input with Sys_error _ -> ());
      try Sys.remove output with Sys_error _ -> ())
    (fun () ->
      let channel = open_out input in
      output_string channel (String.concat " " (List.map string_of_float numbers));
      close_out channel;

      let command =
        Printf.sprintf "%s %s %s" executable (Filename.quote input)
          (Filename.quote output)
      in

      match Sys.command command with
      | 0 ->
          let result = open_in output in
          let text =
            Fun.protect
              ~finally:(fun () -> close_in result)
              (fun () -> String.trim (input_line result))
          in
          (match float_of_string_opt text with
          | Some value -> value
          | None ->
              failwith
                (Printf.sprintf "unexpected output from the Go helper: '%s'" text))
      | status ->
          failwith (Printf.sprintf "the Go helper exited with status %d" status))

let () =
  let arguments = List.tl (Array.to_list Sys.argv) in
  let numbers = if arguments = [] then default_numbers else parse_numbers arguments in

  if numbers = [] then begin
    prerr_endline "error: no numbers to average";
    exit 1
  end;

  try
    let average = calculate_average numbers in
    Printf.printf "The average of %d value(s) is: %.2f\n" (List.length numbers)
      average
  with Failure message ->
    Printf.eprintf "error: %s\n" message;
    exit 1
