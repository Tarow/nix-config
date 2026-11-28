{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.claude-code;
in {
  options.tarow.claude-code.enable = lib.mkEnableOption "Claude Code";

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;

      context = ../opencode/AGENTS.md;
      skills = ../opencode/skills;
    };
  };
}
