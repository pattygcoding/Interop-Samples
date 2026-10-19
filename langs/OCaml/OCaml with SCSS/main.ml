(* Interop sample: OCaml driving the Dart Sass compiler.
 *
 * The SCSS module in `average_calculator.scss` computes the mean of a list of
 * numbers. OCaml configures it with the numbers under test, compiles it with
 * `sass`, and reads the result back out of the generated CSS.
 *
 * See README.md for build and run instructions. *)

let default_numbers = [ 10.0; 20.0; 30.0; 40.0; 50.0 ]

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

(* Pull the value of the --average custom property out of the compiled CSS. *)
let extract_average css =
  let marker = "--average:" in
  let marker_length = String.length marker in
  let length = String.length css in

  let rec find index =
    if index + marker_length > length then None
    else if String.sub css index marker_length = marker then Some (index + marker_length)
    else find (index + 1)
  in

  let is_value_char = function '0' .. '9' | '.' | '-' -> true | _ -> false in

  match find 0 with
  | None -> failwith "could not find --average in the compiled CSS"
  | Some start ->
      let first = ref start in

      while !first < length && (css.[!first] = ' ' || css.[!first] = '\t') do
        incr first
      done;

      let last = ref !first in

      while !last < length && is_value_char css.[!last] do
        incr last
      done;

      float_of_string (String.sub css !first (!last - !first))

(* Render a float the way Sass writes numbers: `10.0` must not become `10.`. *)
let render_number value = Printf.sprintf "%.10g" value

let calculate_average numbers =
  let directory = Filename.get_temp_dir_name () in
  let entry = Filename.concat directory "interop-average-entry.scss" in
  let output = Filename.concat directory "interop-average-result.css" in

  Fun.protect
    ~finally:(fun () ->
      (try Sys.remove entry with Sys_error _ -> ());
      try Sys.remove output with Sys_error _ -> ())
    (fun () ->
      let channel = open_out entry in

      Printf.fprintf channel "@use \"average_calculator\" with ($numbers: (%s));\n"
        (String.concat ", " (List.map render_number numbers));

      close_out channel;

      (* The module lives beside this script; fall back to the working
         directory when the interpreter does not report a usable path. *)
      let beside_script = Filename.dirname (Sys.argv.(0)) in

      let load_path =
        if Sys.file_exists (Filename.concat beside_script "average_calculator.scss")
        then beside_script
        else "."
      in

      let command =
        Printf.sprintf "sass --no-source-map --load-path %s %s %s"
          (Filename.quote load_path) (Filename.quote entry) (Filename.quote output)
      in

      match Sys.command command with
      | 0 ->
          let result = open_in output in

          let css =
            Fun.protect
              ~finally:(fun () -> close_in result)
              (fun () ->
                let buffer = Buffer.create 1024 in

                (try
                   while true do
                     Buffer.add_string buffer (input_line result);
                     Buffer.add_char buffer '\n'
                   done
                 with End_of_file -> ());

                Buffer.contents buffer)
          in

          extract_average css
      | status -> failwith (Printf.sprintf "sass exited with status %d" status))

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
