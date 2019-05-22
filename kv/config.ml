open Mirage

let remote =
  let doc = Key.Arg.info ~doc:"Remote git repository." ["r"; "remote"] in
  Key.(create "remote" Arg.(opt string "git://github.com/mirage/irmin" doc))

let dns_handler =
  let packages = [
    package "logs" ;
    package "irmin-mirage-git";
  ] in
  foreign
    ~deps:[abstract nocrypto]
    ~keys:[Key.abstract remote]
    ~packages
    "Unikernel.Main"
    (pclock @-> resolver @-> conduit @-> job)

let () =
  let net = generic_stackv4 default_network in
  register "kv"
    [dns_handler $ default_posix_clock $ resolver_dns net $ conduit_direct ~tls:true net]
