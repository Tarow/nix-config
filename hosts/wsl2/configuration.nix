{
  config,
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}: {
  system.stateVersion = "24.05";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "core"
      "docker"
      "shells"
      "stylix"
      "wsl"
    ])
    {core.configLocation = "~/nix-config#wsl2";}
  ];

  environment.systemPackages = [pkgs.wget];
}
