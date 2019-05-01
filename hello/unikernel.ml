open Lwt.Infix

module Main
    (Console : Mirage_types_lwt.CONSOLE)
    (Pclock : Mirage_types_lwt.PCLOCK) =
struct
  module Store = Irmin_mirage.Git.Mem.KV (Irmin.Contents.String)
  module Info = Irmin_mirage.Info (Pclock)

  let start console pclock _nocrypto =
    let cfg = Irmin_mem.config () in
    Store.Repo.v cfg >>= Store.master >>= fun t ->
    Store.set_exn t
      ~info:(Info.f pclock "testing" ~author:"aaa")
      [ "a"; "b"; "c" ] "hello"
    >>= fun () ->
    Store.get t [ "a"; "b"; "c" ] >>= fun s -> Console.log console s
end
