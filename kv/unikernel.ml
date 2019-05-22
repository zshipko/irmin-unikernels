open Lwt.Infix
open Mirage_types_lwt

module Main
    (P : PCLOCK)
    (RES : Resolver_lwt.S)
    (CON : Conduit_mirage.S) =
struct
  module ROStore = Irmin_mirage_git.KV_RO (Irmin_git.Mem)
  module RWStore = Irmin_mirage_git.KV_RW (Irmin_git.Mem) (P)

  let ro_store_connect conduit resolver git =
      ROStore.connect git ~conduit ~resolver (Key_gen.remote ())

  let rw_store_connect conduit resolver git =
      RWStore.connect git () ~conduit ~resolver (Key_gen.remote ())

  let start  _pclock resolver conduit _ =
    Irmin_git.Mem.v (Fpath.v ".") >>= function
    | Error err ->
        Lwt.fail_with (Fmt.to_to_string Irmin_git.Mem.pp_error err)
    | Ok git ->
      (* Create a writable store*)
      rw_store_connect conduit resolver git >>= fun rw ->

        (* Get an existing value *)
      RWStore.get rw (Mirage_kv.Key.v "README.md") >>= function
      | Error _ -> Lwt.fail_with "Cannot get README.md"
      | Ok readme -> Logs.info (fun pr -> pr "%s" readme);
        Lwt.return_unit >>= fun () ->

      (* Set a new value *)
      RWStore.set rw (Mirage_kv.Key.v "abc") "123" >>= fun _ ->

      (* A read-only store using the same backing git repository *)
      ro_store_connect conduit resolver git >>= fun ro ->
      ROStore.get ro (Mirage_kv.Key.v "abc") >>= (function
      | Error _ -> Lwt.fail_with "Invalid key"
      | Ok value -> Logs.info (fun pr -> pr "%s" value);
        Lwt.return_unit
      )
end
