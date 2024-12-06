{ pkgs, lib, config, inputs, ... }:
let
  cfg = config.tarow.gaming;
in
{
  options.tarow.gaming = {
    enable = lib.options.mkEnableOption "Gaming setup";
  };

  config = lib.mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
    };

    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [ protonup lutris ];
    environment.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    };
  };
}
