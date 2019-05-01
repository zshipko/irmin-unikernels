open Mirage

let packages = [ package "irmin-mirage" ]

let deps = [ abstract nocrypto ]

let main = foreign "Unikernel.Main" ~deps ~packages (console @-> pclock @-> job)

let () = register "hello" [ main $ default_console $ default_posix_clock ]
