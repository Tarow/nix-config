{lib, ...}: {
  home.stateVersion = "24.11";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "core"
      "git"
      "shells"
      "sops"
      "stylix"
    ])
    {
      facts = import ../facts.nix // {ip4Address = "10.1.1.99";};
      core.configLocation = "~/nix-config#homeserver";
    }
    {
      stacks = {
        enable = true;
        #audiobookshelf.enable = true;
        #calibre.enable = true;
        #dozzle.enable = true;
        #filebrowser.enable = true;
        healthchecks.enable = true;

        traefik = {
          domain = "ntasler.de";
        };
      };
    }
  ];
}
