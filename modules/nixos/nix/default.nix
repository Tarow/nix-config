{ lib, config, pkgs, inputs, outputs, ... }:
{
  nix = {
    settings = {
      extra-experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Necessary for comma to work now. Disable later once issue below is resolved
    # https://github.com/nix-community/comma/issues/43
    channel.enable = true;
  };

  nixpkgs = {
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
