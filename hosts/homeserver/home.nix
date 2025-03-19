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
    facts.ip4Address = "10.1.1.99";
    core.configLocation = "~/nix-config#homeserver";

    stacks = {
      enable = true;
      adguard.enable = true;
      #audiobookshelf.enable = true;
      #calibre.enable = true;
      #dozzle.enable = true;
      #dockdns.enable = true;
      #filebrowser.enable = true;
      #healthchecks.enable = true;
      #homepage.enable = true;
      #streaming.enable = true;
      #stirling-pdf.enable = true;
      #immich.enable = true;
      #paperless.enable = true;
      #wg-easy.enable = true;
      pangolin.enable = true;
      pangolin.domain = "ntasler.de";
      traefik = {
        #  enable = true;
        domain = "ntasler.de";
      };
    };
  };
}
