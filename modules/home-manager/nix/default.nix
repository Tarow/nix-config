# This module is not enabled using an enable flag, because it contains essential settings, that should always be active.
{ inputs
, outputs
, lib
, config
, osConfig ? { }
, pkgs
, vars
, ...
}: {
  nix = {
    package = pkgs.unstable.nix;
    gc.automatic = true;
    # Run garbage collection every day at 12:30
    gc.frequency = if pkgs.stdenv.isLinux then "12:30" else "daily";
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };
  # Automatically start and drop systemd services as needed
  systemd.user.startServices = "sd-switch";

  # Disable nixpkgs overlays, if home-manager is running as submodule with useGlobalPkgs=true 
  nixpkgs = lib.mkIf (!(config.submoduleSupport.enable && osConfig.home-manager.useGlobalPkgs)) {
    # You can add overlays here
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };


}
