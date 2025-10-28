{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.tarow.cmdmark;
in {
  imports = [inputs.cmdmark.homeModules.cmdmark];
  options.tarow.cmdmark = {
    enable = lib.options.mkEnableOption "cmdmark";
  };
  config = lib.mkIf cfg.enable {
    programs.fish.interactiveShellInit = ''
      bind \cb 'commandline -r -- (cmdmark search)'
    '';

    programs.cmdmark = {
      enable = true;
      settings = {
        vars = {
          sshHost = {
            multi = false;
            options = ["localhost" "user@remote.example.com"];
          };

          service = {
            multi = false;
            options_cmd = "systemctl list-units --type=service --no-legend | awk '{print $1}'";
          };

          containers = {
            multi = true;
            delimiter = " ";
            options_cmd = "podman ps --format '{{.Names}}'";
          };
        };

        commands = [
          # Ripgrep

          # Journalctl
          {
            title = "Follow Systemd Service Logs";
            cmd = "journalctl -u {{service}} -f";
          }
          {
            title = "Show Last 100 Lines of Service Log";
            cmd = "journalctl -u {{service}} -n 100";
          }
          {
            title = "Search Journal Logs by Keyword";
            cmd = "journalctl -g '{{keyword}}'";
          }
          {
            title = "Show Logs Since Yesterday";
            cmd = "journalctl --since yesterday";
          }

          # SSH / file transfer
          {
            title = "SSH to Host";
            cmd = "ssh {{sshHost}}";
          }
          {
            title = "Copy File to SSH Host";
            cmd = "scp {{localPath}} {{sshHost}}:{{remotePath}}";
            vars = {
              remotePath = {
                multi = false;
                options = ["/tmp" "/home/$USER"];
              };
            };
          }

          # Docker / Podman
          {
            title = "Follow Docker Container Logs";
            cmd = "docker logs -f --tail 200 {{container}}";
            vars = {
              container = {
                multi = false;
                options_cmd = "docker ps --format '{{.Names}}'";
              };
            };
          }
          {
            title = "Stop Docker Containers";
            cmd = "docker stop {{containers}}";
          }

          {
            title = "Show Podman Container Status";
            cmd = "podman ps -a --filter 'name={{containers}}'";
            vars = {
              containers = {
                multi = true;
                delimiter = ",";
                options_cmd = "podman ps --format '{{.Names}}'";
              };
            };
          }
          {
            title = "Follow Podman Container Logs";
            cmd = "podman logs -f {{container}}";
            vars = {
              container = {
                multi = false;
                options_cmd = "podman ps --format '{{.Names}}'";
              };
            };
          }
          {
            title = "Stop Podman Containers";
            cmd = "podman stop {{containers}}";
          }
          {
            title = "Restart Podman Containers";
            cmd = "podman restart {{containers}}";
          }

          # Systemd
          {
            title = "Restart a Systemd Service";
            cmd = "sudo systemctl restart {{service}}";
          }
          {
            title = "Show Service Status";
            cmd = "systemctl status {{service}}";
          }

          # Disk & memory
          {
            title = "Check Disk Usage";
            cmd = "df -h {{path}}";
          }
          {
            title = "Check Free Inodes";
            cmd = "df -i {{path}}";
          }
          {
            title = "Disk Usage of Directory Contents";
            cmd = "du -sh {{path}}/*";
          }
          {
            title = "Monitor Free Memory";
            cmd = "watch -n 2 free -h";
          }
          {
            title = "Monitor CPU Usage";
            cmd = "top -o %CPU";
          }
          {
            title = "Check Memory Usage by Process";
            cmd = "ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 20";
          }

          # Processes
          {
            title = "Search Running Processes";
            cmd = "ps aux | grep {{pattern}}";
          }
          {
            title = "Kill Process by Name";
            cmd = "pkill -f {{processName}}";
            vars = {
              processName = {
                multi = false;
                options_cmd = "ps -eo comm | tail -n +2 | sort -u";
              };
            };
          }

          # Files
          {
            title = "Find Large Files";
            cmd = "find {{path}} -type f -size +{{size}}M -exec ls -lh {} \\;";
          }
          {
            title = "Find Recently Modified Files (Last 24h)";
            cmd = "find {{path}} -type f -mtime -1";
          }
          {
            title = "Grep for a Pattern in a File";
            cmd = "grep '{{pattern}}' {{file}}";
          }
          {
            title = "Grep with Context";
            cmd = "grep -C {{lines}} '{{pattern}}' {{file}}";
          }
          {
            title = "Grep Ignoring Case";
            cmd = "grep -i '{{pattern}}' {{file}}";
          }
          {
            title = "Grep Recursive with Line Numbers";
            cmd = "grep -rn '{{pattern}}' {{path}}";
          }
          {
            title = "Grep Excluding Certain Files";
            cmd = "grep '{{pattern}}' {{path}} --exclude-dir=node_modules --exclude=*.log";
          }
          {
            title = "Tail Local Log File";
            cmd = "tail -f {{logFile}}";
          }
          {
            title = "Tail Last N Lines of File";
            cmd = "tail -n {{lines}} {{file}}";
          }
          {
            title = "SSH and Tail a Log File";
            cmd = "ssh {{sshHost}} 'tail -f {{logFile}}'";
          }

          # Compression
          {
            title = "Compress Files into Tar.gz";
            cmd = "tar -czvf {{archiveName}} {{files}}";
            vars = {
              files = {
                multi = true;
                delimiter = " ";
                allowFreeform = true;
              };
            };
          }
          {
            title = "Extract Tar.gz Archive";
            cmd = "tar -xzvf {{archiveName}}";
          }

          # Network
          {
            title = "Check Open Ports";
            cmd = "ss -tuln | grep {{port}}";
          }
          {
            title = "Show Listening TCP Ports";
            cmd = "lsof -iTCP -sTCP:LISTEN -P -n";
          }
          {
            title = "Monitor Network Traffic";
            cmd = "iftop -i {{interface}}";
          }
          {
            title = "Ping a Host";
            cmd = "ping -c 4 {{host}}";
          }
          {
            title = "Traceroute to Host";
            cmd = "traceroute {{host}}";
          }

          # Package management
          {
            title = "List Installed Packages";
            cmd = "dpkg -l | grep {{packageName}}";
          }

          # Misc useful
          {
            title = "Locate File";
            cmd = "locate {{filename}}";
          }
          {
            title = "Check Listening Sockets with Netstat";
            cmd = "netstat -tulnp";
          }
          {
            title = "Show System Uptime";
            cmd = "uptime";
          }
          {
            title = "Show Logged In Users";
            cmd = "who";
          }
        ];
      };
    };
  };
}
