{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.podman;
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
          ExecStart = "${lib.getExe config.services.podman.package} system prune -af";
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
