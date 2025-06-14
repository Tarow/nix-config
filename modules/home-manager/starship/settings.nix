lib: {
  format = lib.concatStrings [
    "$battery"
    "$directory"
    "$git_branch"
    "$git_state"
    "$git_status"
    "$fill"
    "$kubernetes"
    "$aws"
    "$cmd_duration"
    "$line_break"
    "$character"
  ];

  directory = {
    style = "blue";
  };

  character = {
    success_symbol = "[❯](purple)";
    error_symbol = "[❯](red)";
    vimcmd_symbol = "[❮](green)";
  };

  git_status = {
    format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
    conflicted = "";
    untracked = "";
    modified = "";
    staged = "";
    renamed = "";
    deleted = "";
    stashed = "≡";
  };

  git_state = {
    format = ''\\([ $state($progress_current/$progress_total)]($style)\\) '';
  };

  git_branch = {
    style = "fg:green";
    symbol = " ";
    format = "[on](white) [$symbol$branch ]($style)";
  };

  cmd_duration = {
    format = "[$duration]($style) ";
    style = "base04";
  };

  fill = {
    symbol = " ";
  };

  aws = {
    format = ''[$symbol($profile )]($style)'';
    symbol = " ";
  };

  kubernetes = {
    disabled = false;
    symbol = "⛵";
    format = ''[$symbol $cluster \($namespace\)]($style) '';
  };
}
