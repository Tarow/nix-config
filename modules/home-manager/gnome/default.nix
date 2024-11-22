{ lib, pkgs, config, ... }:
let
  cfg = config.tarow.gnome;

in
{
  options.tarow.gnome = {
    enable = lib.options.mkEnableOption "Gnome";
  };
  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          (lib.hm.gvariant.mkTuple [ "xkb" "eu" ])
        ];
      };

      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = [ "<Shift><Super>s" ];
      };
    };

    # GNOME does not see new applications installed with HM unless until next login.
    # Workaround to make GNOME find applications without needing to relogin again
    # See https://github.com/NixOS/nixpkgs/issues/12757#issuecomment-2253490852
    home.activation.copyDesktopFiles = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if [ -d "${config.home.homeDirectory}/.nix-profile/share/applications" ]; then
        rm -rf ${config.home.homeDirectory}/.local/share/applications
        mkdir -p ${config.home.homeDirectory}/.local/share/applications
        for file in ${config.home.homeDirectory}/.nix-profile/share/applications/*; do
          ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
        done
      fi
    '';
  };
}
