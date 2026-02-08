{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./stacks.nix
    {
      tarow = lib.tarow.enableModules [
        "core"
        "fastfetch"
        "git"
        "housekeeping"
        "nh"
        "shells"
        "sops"
        "starship"
        "stylix"
        "vscode"
        "neovim"
        "podman"
        "scrutiny"
      ];
    }
  ];

  home.packages = with pkgs; [isd];

  home.stateVersion = "25.11";
  sops.secrets."ssh_authorized_keys".path = "${config.home.homeDirectory}/.ssh/authorized_keys";
  tarow = {
    facts.ip4Address = "192.168.178.2";
    sops.extraSopsFiles = [../../secrets/relsat/secrets.yaml];
  };
}
