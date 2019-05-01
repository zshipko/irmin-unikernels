open Lwt.Infix

module Main
    (Console : Mirage_types_lwt.CONSOLE)
    (Pclock : Mirage_types_lwt.PCLOCK)
    (Resolver : Resolver_lwt.S)
    (Conduit : Conduit_mirage.S) =
struct
  module Store = Irmin_mirage.Git.Mem.KV (Irmin.Contents.String)
  module Sync = Irmin.Sync (Store)
  module Info = Irmin_mirage.Info (Pclock)

  let start console pclock resolver conduit _nocrypto =
    let cfg = Irmin_mem.config () in
    Store.Repo.v cfg >>= Store.master >>= fun t ->
    Sync.pull_exn t
      (Store.remote ~resolver ~conduit "git://github.com/mirage/irmin")
      `Set
    >>= fun () ->
    Console.log console "Pulled from mirage/irmin" >>= fun () ->
    Store.get t [ "README.md" ] >>= fun s -> Console.log console s
end
