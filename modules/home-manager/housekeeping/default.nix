{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.housekeeping;

  deleteStaleStoreLinks = pkgs.writeShellApplication {
    name = "delete_stale_store_links";
    runtimeInputs = with pkgs; [coreutils fd bash];
    text = builtins.readFile ./delete_stale_links.sh;
  };
in {
  options.tarow.housekeeping = {
    enable = lib.options.mkEnableOption "Housekeeping";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [deleteStaleStoreLinks];

    systemd.user = {
      timers."housekeeping" = {
        Timer = {
          OnCalendar = "02:30";
          Persistent = true;
        };
        Install = {
          WantedBy = ["timers.target"];
        };
      };
      services."housekeeping" = {
        Service = {
          Type = "oneshot";
          ExecStart = "${lib.getExe deleteStaleStoreLinks} ${config.home.homeDirectory}";
        };
      };
    };
  };
}
