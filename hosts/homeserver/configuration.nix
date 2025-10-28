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
    facts.ip4Address = "10.1.1.99";
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
    samba = {
      enable = true;
      extraSettings = {
        "public" = {
          "path" = "/mnt/hdd1/shares/public";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "yes";
          "create mask" = "0666";
          "directory mask" = "0777";
        };
        "${config.tarow.facts.username}" = let
          user = config.tarow.facts.username;
        in {
          "path" = "/mnt/hdd1/shares/${user}";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = user;
          "force group" = user;
          "valid users" = user;
        };
        "hdd" = let
          user = config.tarow.facts.username;
        in {
          "path" = "/mnt/hdd1";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = user;
          "force group" = user;
          "valid users" = user;
        };
      };
    };
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
  networking = rec {
    firewall = {
      allowedUDPPorts = [53 80 443 51820 51825];
      allowedTCPPorts = [21 53 80 443 8888] ++ (lib.range 40000 40009);
    };
    hostName = "homeserver";
    defaultGateway = "10.1.1.1";
    nameservers = [defaultGateway "1.1.1.1" "9.9.9.9"];
    resolvconf.extraOptions = ["timeout:2"];

    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = config.tarow.facts.ip4Address;
          prefixLength = 24;
        }
      ];
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 9191;
    enabledCollectors = ["systemd"];
  };

  services.scrutiny = {
    enable = true;
  };
  services.borgbackup.jobs = let
    ping = lib.getExe (pkgs.writeShellScriptBin "notify-backup" ''
      success=$([ "''${2}" -eq 0 ] && echo true || echo false)
      duration="$(( $(date +%s) - "''${START_TIME}" ))s"
      token="$(< ${config.sops.secrets."gatus/external_endpoint_token".path})"
      ${lib.getExe pkgs.curl} --retry 3 --retry-max-time 30 \
        -H "Authorization: Bearer ''${token}" -X POST "https://gatus.ntasler.de/api/v1/endpoints/backups_$1/external?success=$success&duration=$duration"
    '');
    base = {
      paths = [
        "${config.tarow.facts.userhome}/stacks"
        "/mnt/hdd1/media/pictures/immich"
        "/mnt/hdd1/shares/niklas"
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
      preHook = "export START_TIME=$(${pkgs.coreutils}/bin/date +%s)";
    };
  in
    {
      remote = {
        repo = "ssh://u363719@u363719.your-storagebox.de:23/./backups/homeserver";
        postHook = "${ping} backup-remote $exitStatus";
      };
      local = {
        repo = "/mnt/hdd1/backups/homeserver";
        postHook = "${ping} backup-local $exitStatus";
      };
    }
    |> lib.mapAttrs (_: job: (base // job));
}
