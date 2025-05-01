{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.wg-client;
in {
  options.tarow.wg-client = with lib; {
  };
  config =
    lib.mkIf cfg.enable {
    };
}
