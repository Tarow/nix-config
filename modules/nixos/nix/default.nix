{
  lib,
  config,
  pkgs,
  inputs,
  outputs,
  ...
}: {
  nix = {
    settings = {
      extra-experimental-features = ["nix-command" "flakes" "pipe-operators"];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    channel.enable = false;

    # Pin nixpkgs and unstable references to the ones used by the flake.
    # This results in tools like "nix search" and "nix run" to use the same nixpkgs instance as the system flake.
    # Also see option `nixpkgs.flake.setFlakeRegistry`
    registry = {
      unstable.flake = inputs.nixpkgs-unstable;
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  nixpkgs = {
    # You can add overlays here
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };
}
