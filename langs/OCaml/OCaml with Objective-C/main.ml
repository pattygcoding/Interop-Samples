(* Interop sample: OCaml driving a compiled Objective-C program.
 *
 * OCaml passes the numbers as command-line arguments to the Objective-C helper
 * and captures the average it prints by redirecting its output to a file.
 *
 * See README.md for build and run instructions. *)

let default_numbers = [ 10.0; 20.0; 30.0; 40.0; 50.0 ]

let executable =
  if Sys.win32 then "average_calculator.exe" else "./average_calculator"

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

(* Render a float without OCaml's trailing dot, which C's strtod still reads but
   which looks odd in a command line. *)
let render_number value = Printf.sprintf "%.10g" value

(* Run the Objective-C helper and return the average it prints. *)
let calculate_average numbers =
  let output = Filename.temp_file "average" ".txt" in

  Fun.protect
    ~finally:(fun () -> try Sys.remove output with Sys_error _ -> ())
    (fun () ->
      let command =
        Printf.sprintf "%s %s > %s" executable
          (String.concat " " (List.map render_number numbers))
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
                (Printf.sprintf "unexpected output from the Objective-C helper: '%s'" text))
      | status ->
          failwith (Printf.sprintf "the Objective-C helper exited with status %d" status))

let () =
  let arguments = List.tl (Array.to_list Sys.argv) in
  let numbers = if arguments = [] then default_numbers else parse_numbers arguments in

  if numbers = [] then begin
    prerr_endline "error: no numbers to average";
    exit 1
  end;

  try
    let average = calculate_average numbers in
    Printf.printf "The average of %d value(s) is: %.2f\n" (List.length numbers) average
  with Failure message ->
    Printf.eprintf "error: %s\n" message;
    exit 1
