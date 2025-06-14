lib: {
  format = lib.concatStrings [
    "$directory"
    "$git_branch"
    "$git_state"
    "$git_status"
    "$fill"
    "$nix_shell"
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

  git_branch = {
    style = "fg:green";
    symbol = "[|](white)  ";
    format = ''[$symbol$branch]($style) '';
  };

  git_state = {
    format = ''\([$state($progress_current/$progress_total)]($style)\) '';
  };

  git_status = {
    format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)]($style)($ahead_behind$stashed)]($style) ";
    conflicted = "";
    untracked = "";
    modified = "";
    staged = "";
    renamed = "";
    deleted = "";
    stashed = "≡";
  };

  cmd_duration = {
    format = "[$duration]($style) ";
    style = "base04";
  };

  nix_shell = {
    format = ''[$symbol$state( \($name\))]($style) '';
    symbol = " ";
    heuristic = true;
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
