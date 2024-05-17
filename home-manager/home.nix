{ inputs, outputs, config, pkgs, ... }:

{

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "niklas";
  home.homeDirectory = "/home/niklas";

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neofetch
    dockdns
  ];

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.shellAliases = {
    hms = "home-manager switch --flake ~/projects/nix/#$USER";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./apps/fish.nix
    ./apps/fzf.nix
    ./apps/git.nix
  ];
}
