(* Prints one dune rule per upstream source file: patched when lib/patches has
   [<file>.patch], copied otherwise. *)
let () =
  let dir = Sys.argv.(1)
  and patches = Sys.argv.(2) in
  Sys.readdir dir
  |> Array.to_list
  |> List.sort compare
  |> List.iter (fun file ->
    if file <> "dune"
    then (
      let patch = Filename.concat patches (file ^ ".patch") in
      if Sys.file_exists patch
      then
        Printf.printf
          {|(rule
 (targets %s)
 (deps %s/%s %s)
 (action
  (with-stdout-to
   %s
   (run patch -s -o - %s/%s %s))))

|}
          file dir file patch file dir file patch
      else
        Printf.printf
          {|(rule
 (copy %s/%s %s))

|}
          dir file file))
;;
