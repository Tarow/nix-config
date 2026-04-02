{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.opencode;
in {
  options.tarow.opencode = {
    enable = lib.mkEnableOption "OpenCode";
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      agents = {
        debug = ./agents/debug.md;
        docs = ./agents/docs.md;
        engineer = ./agents/engineer.md;
        orchestrator = ./agents/orchestrator.md;
        refactor = ./agents/refactor.md;
        reviewer = ./agents/reviewer.md;
        security = ./agents/security.md;
        tester = ./agents/tester.md;
      };
      commands = {
        commit = ./commands/commit.md;
        review-pr = ./commands/review-pr.md;
        security-pr = ./commands/security-pr.md;
        test = ./commands/test.md;
      };
      settings = {
        #model = "github-copilot/gpt-5-mini";
        #small_model = "github-copilot/gpt-4.1";
        username = config.tarow.facts.person.name;
        compaction = {
          auto = false;
          prune = true;
        };
        agent = {
          explore = {
            # model = "github-copilot/gpt-5-mini";
          };
          general = {
            #model = "github-copilot/gpt-5-mini";
          };
          title = {
            #model = "github-copilot/gpt-4.1";
          };
          summary = {
            #model = "github-copilot/gpt-5-mini";
          };
          compaction = {
            #model = "github-copilot/gpt-5-mini";
          };
          plan = {
            #model = "github-copilot/claude-sonnet-4.5";
          };
          build = {
            #model = "github-copilot/gpt-5.2-codex";
            prompt = ''
              You are a senior software engineer. Follow established project conventions as documented in AGENTS.md. Write clean, maintainable, production-ready code.

              When working on complex tasks, consider delegating to specialized subagents:
              - @engineer for focused implementation subtasks
              - @tester for writing tests
              - @reviewer for code quality review
              - @security for security-focused review
              - @refactor for targeted refactoring
              - @debug for investigating bugs
              - @docs for documentation

              For simple, straightforward changes, handle them directly without delegation.
            '';
          };
        };
      };
    };

    home.file.".config/opencode/skills".source = ./skills;
  };
}
