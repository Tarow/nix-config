{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.11";

  tarow = {
    core = {
      enable = true;
      configLocation = "~/nix-config#homeserver";
    };
    bootLoader.enable = true;
    shells.enable = true;
    sops = {
      enable = true;
      extraSopsFiles = [../../secrets/homeserver/secrets.yaml];
    };

    wg-server.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  time.timeZone = "Europe/Berlin";
  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking.firewall.allowedUDPPorts = [53 80 443 51820];
  networking.firewall.allowedTCPPorts = [21 53 80 443 8888] ++ (lib.range 40000 40009);
  networking.hostName = "homeserver";

  services.prometheus.exporters.node = {
      enable = true;
      port = 9191;
      enabledCollectors = [ "systemd" ];
  };

  services.borgbackup.jobs = let
    ping = endpoint: "${lib.getExe pkgs.curl} --retry 3 --retry-max-time 30 https://healthchecks.ntasler.de/ping/uG6NthbpgAp0NQjlY5vzyg/${endpoint}";
    base = {
      paths = [
        "${config.tarow.facts.userhome}/stacks"
        "/mnt/hdd1/media/pictures/immich"
      ];
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      };
      compression = "auto,lzma";
      startAt = "daily";
      dateFormat = "+%Y-%m-%dT%H:%M:%S";
      extraArgs = "-v --debug --show-rc";
      extraCreateArgs = "--stats --progress";

      failOnWarnings = false;

      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 7; 
        weekly = 4;
        monthly = 3;
      };
    }; 
  in {
    remote = {
      repo = "ssh://u363719@u363719.your-storagebox.de:23/./backups/homeserver";
      preHook = ping "homeserver-remote/start?create=1";
      postHook = ping "homeserver-remote/$exitStatus";
    };  
    local = {
      repo = "/mnt/hdd1/backups/homeserver";
      preHook = ping "homeserver-local/start?create=1";
      postHook = ping "homeserver-local/$exitStatus";
    };
  } |> lib.mapAttrs (_: job: (base // job));


}
