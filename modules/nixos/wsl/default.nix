{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.wsl;
in {
  imports = [inputs.nixos-wsl.nixosModules.default];

  options.tarow.wsl = {
    enable = lib.options.mkOption {
      type = lib.types.bool;
      example = ''true'';
      default = false;
      description = "Whether to enable WSL support.";
    };
  };

  config = lib.mkIf cfg.enable {
    wsl = {
      enable = true;
      defaultUser = config.tarow.facts.username;
      startMenuLaunchers = true;
    };

    # Fixes Home-Manager applications not appearing in Start Menu
    system.activationScripts.copy-user-launchers = lib.stringAfter [] ''
      for x in applications icons; do
        echo "setting up /usr/share/''${x}..."
        targets=()
        if [[ -d "/home/${config.wsl.defaultUser}/.nix-profile/share/$x" ]]; then
          targets+=("/home/${config.wsl.defaultUser}/.nix-profile/share/$x/.")
        fi

        if (( ''${#targets[@]} != 0 )); then
          mkdir -p "/usr/share/$x"
          ${pkgs.rsync}/bin/rsync -ar --delete-after "''${targets[@]}" "/usr/share/$x"
        else
          rm -rf "/usr/share/$x"
        fi
      done
    '';
  };
}
