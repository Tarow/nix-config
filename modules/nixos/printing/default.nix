{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.printing;
in {
  options.tarow.printing = {
    enable = lib.options.mkEnableOption "Printing";
  };

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.printing.drivers = [pkgs.brlaser];
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
