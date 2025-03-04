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
      };
    };
  };
}
