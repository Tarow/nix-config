{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.fastfetch;
in {
  options.tarow.fastfetch = {
    enable = lib.mkEnableOption "fastfetch";
  };

  config = lib.mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          type = "auto";
          source = "${./lambda.png}";
          height = 18;
          padding = {
            right = 5;
          };
        };
        general = {
          multithreading = true;
        };
        display = {
          separator = "➜   ";
        };
        modules = [
          {
            type = "title";
            format = "                                {6}{7}{8}";
          }
          {
            type = "custom";
            format = "┌──────────────────────────────────────────────────────────────────────────────┐";
          }
          {
            key = "     OS           ";
            keyColor = "green";
            type = "os";
          }
          {
            key = "    󰌢 Machine      ";
            keyColor = "cyan";
            type = "host";
          }
          {
            key = "     Kernel       ";
            keyColor = "blue";
            type = "kernel";
          }
          {
            key = "    󰅐 Uptime       ";
            keyColor = "green";
            type = "uptime";
          }
          {
            key = "     Packages     ";
            keyColor = "cyan";
            type = "packages";
          }
          {
            key = "     WM           ";
            keyColor = "blue";
            type = "wm";
          }
          {
            key = "     Shell        ";
            keyColor = "green";
            type = "shell";
          }
          {
            key = "     Terminal     ";
            keyColor = "cyan";
            type = "terminal";
          }
          {
            key = "     Font         ";
            keyColor = "blue";
            type = "terminalfont";
          }
          {
            key = "    󰻠 CPU          ";
            keyColor = "green";
            type = "cpu";
          }
          {
            key = "    󰍛 GPU          ";
            keyColor = "cyan";
            type = "gpu";
          }
          {
            key = "    󰑭 Memory       ";
            keyColor = "blue";
            type = "memory";
          }
          {
            key = "     Wifi         ";
            keyColor = "green";
            type = "wifi";
          }
          {
            key = "    󰩟 Local IP     ";
            keyColor = "cyan";
            type = "localip";
            compact = true;
          }
          {
            type = "custom";
            format = "└──────────────────────────────────────────────────────────────────────────────┘";
          }
          {
            type = "colors";
            paddingLeft = 34;
            symbol = "circle";
            block = {
              width = 10;
            };
          }
        ];
      };
    };
  };
}
