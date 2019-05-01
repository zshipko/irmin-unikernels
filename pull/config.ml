open Mirage

let packages = [ package "irmin-mirage" ]

let deps = [ abstract nocrypto ]

let main =
  foreign "Unikernel.Main" ~deps ~packages
    (console @-> pclock @-> resolver @-> conduit @-> job)

let net = generic_stackv4 default_network

let () =
  register "pull"
    [ main
      $ default_console
      $ default_posix_clock
      $ resolver_unix_system
      $ conduit_direct ~tls:true net
    ]
