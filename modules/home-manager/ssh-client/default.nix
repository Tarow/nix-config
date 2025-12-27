{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.sshClient;
in {
  options.tarow.sshClient = {
    enable = lib.options.mkEnableOption "SSH Client Config";
  };
  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        homeserver = {
          host = "ntasler ntasler.de";
          hostname = "ntasler.de";
          user = "niklas";
        };
        jkammering = {
          host = "jkammering jkammering.de";
          hostname = "jkammering.de";
          user = "jonvus";
        };
        relsat = {
          host = "relsat relsat.de";
          hostname = "relsat.de";
          user = "niklas";
        };
      };
    };
  };
}
