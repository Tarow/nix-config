{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.gaming;

  customLutris = pkgs.lutris-unwrapped.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "lutris";
      repo = "lutris";
      rev = "v0.5.18";
      hash = "sha256-dI5hqWBWrOGYUEM9Mfm7bTh7BEc4e+T9gJeiZ3BiqmE=";
    };
  });
in
{
  options.tarow.gaming = {
    enable = lib.options.mkEnableOption "Gaming setup";
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ protonup lutris wine ];
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };

    #programs.nix-ld = {
    #  enable = true;
    #  libraries = pkgs.steam-run.fhsenv.args.multiPkgs pkgs;
    #};
  };
}
