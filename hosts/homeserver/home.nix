{lib, ...}: {
  imports = [
    {
      tarow = lib.tarow.enableModules [
        "core"
        "git"
        "shells"
        "sops"
        "stylix"
      ];
    }
  ];

  home.stateVersion = "24.11";

  tarow = {
    facts = import ../facts.nix // {ip4Address = "10.1.1.99";};
    core.configLocation = "~/nix-config#homeserver";

    stacks = {
      enable = true;
      adguard.enable = true;
      audiobookshelf.enable = true;
      calibre.enable = true;
      dozzle.enable = true;
      filebrowser.enable = true;
      healthchecks.enable = true;
      homepage.enable = true;
      streaming.enable = true;
      immich.enable = true;
      traefik = {
        enable = true;
        domain = "ntasler.de";
      };
    };
  };
}
