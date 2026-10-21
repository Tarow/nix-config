{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.podman;

  script = pkgs.writeShellScriptBin "podman-cleanup" ''
    ${lib.getExe config.services.podman.package} system prune -af;

    # Recreate unused network for stacks that sablier scaled down
    ${pkgs.systemd}/bin/systemctl --user restart 'podman-*-network.service';
  '';
in {
  options.tarow.podman.enable = lib.options.mkEnableOption "Podman";

  config = lib.mkIf cfg.enable {
    services.podman.enable = true;

    systemd.user = {
      timers."podman-cleanup" = {
        Timer = {
          OnCalendar = "03:00";
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
      services."podman-cleanup" = {
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe script;
        };
      };
    };

    programs.fish.shellAbbrs = {
      pl = "podman logs";
      plf = "podman logs -f";
      psh = {
        expansion = "podman exec -it % /bin/sh";
        setCursor = true;
      };
      prun = {
        expansion = "podman run --rm -it % /bin/sh";
        setCursor = true;
      };
    };
  };
}
