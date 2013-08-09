let dir =
  if Array.length Sys.argv > 1 then
    Sys.argv.(1)
  else
    Filename.concat (Sys.getcwd ()) "cow_tests"

let slurp filename =
  let file = open_in filename in
  let size = in_channel_length file in
  let buf = String.create size in
  begin
    really_input file buf 0 size;
    buf
  end

let process file =
  let html = (Filename.chop_extension file) ^ ".html" in
  if not (Sys.file_exists html) then (
    Printf.eprintf "File %s does not exist.\n" html;
    exit 2;
  );
  let expected = slurp html in
  let observed = Md_lib.Md.(html_of_md (parse (lex (slurp file)))) in
  if expected <> observed then
    Printf.fprintf stderr "FAILURE: %s\n" file
  else
    Printf.fprintf stderr "SUCCESS: %s\n" file

let () =
  let () = prerr_endline ("reading directory " ^ dir) in
  let files = Sys.readdir dir in
  let files = Array.to_list files in
  let files = List.map (fun f -> Filename.concat dir f) files in
  let md_files = List.filter (fun f -> Filename.check_suffix f ".md") files in
  List.iter process md_files
