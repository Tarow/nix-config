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
      "nh"
      "shells"
      "stylix"
      "wsl"
    ])
  ];

  environment.systemPackages = [pkgs.wget];
}
