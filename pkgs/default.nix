pkgs: {
    dockdns = pkgs.callPackage ./dockdns.nix { };
    discovr = pkgs.callPackage ./discovr.nix { };
}