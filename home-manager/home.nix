{ inputs, outputs, lib, config, pkgs, vars, ... }@args:

{

  imports = [
    ./docker
    ./apps/fish.nix
    ./apps/fzf.nix
    ./apps/git.nix
    ./apps/vscode.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.toLower vars.user.name;
  home.homeDirectory = vars.user.home;

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
    go
    neofetch
    less
    dockdns
    discovr
    neovim
    eza
    bat
    nixpkgs-fmt
    nil
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.shellAliases = {
    hms = "home-manager switch -b bak --flake ~/projects/nix-config/#$USER";
    gl = "git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit";
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    k = "kubectl";
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    cat = "bat --paging=never";
    tree = "eza -T";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  docker.enable = true;
}
