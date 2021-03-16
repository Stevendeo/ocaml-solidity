(**************************************************************************)
(*                                                                        *)
(*  Copyright (c) 2021 OCamlPro & Origin Labs                             *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*  This file is distributed under the terms of the GNU Lesser General    *)
(*  Public License version 2.1, with the special exception on linking     *)
(*  described in the LICENSE.md file in the root directory.               *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

let typecheck = ref true
let postcheck = ref true

let disactiv_typecheck () = typecheck := false
let disactiv_postcheck () =
  disactiv_typecheck ();
  postcheck := false


let main () =
  let arg_list = Arg.align [
      "--version", Arg.Unit (fun () ->
          Format.eprintf "Solidity Parser & Typechecker"; exit 0),
      " Show version and exit";

      "--no-typecheck", Arg.Unit disactiv_typecheck,
      " Disactivates the typechecker";

      "--no-postcheck", Arg.Unit disactiv_postcheck,
      " Disactivates the postchecker"
    ]
  in

  let arg_usage = String.concat "\n" [
      "solp [OPTIONS] FILE [OPTIONS]";
      "";
      "This tool will parse a Solidity file (.sol) and print the result";
      "";
      "Available options:";
    ]
  in
  let file = ref None in
  Arg.parse arg_list (fun a ->
      Format.eprintf "Argument %s@." a;
      if !file <> None then begin
        Format.eprintf "More than one file specified";
        exit 1
      end;
      file := Some a;
    ) arg_usage;
  match !file with
  | None ->
      Arg.usage arg_list arg_usage;
      exit 1
  | Some file ->
      let program = Solidity_parser.parse file in

      Format.printf "Parsed code:\n%s@."
        (Solidity_printer.string_of_program program);

      let () = if !typecheck then Solidity_typechecker.type_program program in

      List.iter (fun m ->
          if !postcheck then ignore @@ Solidity_postprocess.checkModule m
        ) program.program_modules;

      ()


let () =
  try
    main ()
  with
  | Solidity_common.GenericError (s) ->
      Format.printf "Generic error: %s@." s
  | Solidity_common.SyntaxError (s, ((c1,l1),(c2,l2))) ->
      Format.printf "Syntax error at ((%d,%d)-(%d,%d)): %s@." c1 l1 c2 l2 s
  | Solidity_common.TypecheckError (s, ((c1,l1),(c2,l2))) ->
      Format.printf "Typecheck error at ((%d,%d)-(%d,%d)): %s@." c1 l1 c2 l2 s