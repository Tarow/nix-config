{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Todos:
  # Check IP subnet
  # OIDC clientSecretHash override
  # Storagebox ssh key authorized hosts
  # disko config
  # borg  backup paths

  system.stateVersion = "25.11";

  tarow = {
    facts.ip4Address = "192.168.178.2";
    nh.enable = true;
    bootLoader.enable = true;
    shells.enable = true;
    sops = {
      enable = true;
      extraSopsFiles = [../../secrets/relsat/secrets.yaml];
    };

    wg-server = {
      enable = true;
      ip = "10.3.3.1/24";
      externalInterface = "enp3s0";
      endpoint = "vpn.relsat.de";
      peers = [
        (import ../../modules/nixos/wg-server/peers.nix config).homeserver
        (import ../../modules/nixos/wg-server/peers.nix config).hermann-phone
      ];
    };

    samba = {
      enable = true;
      extraSettings =
        {
          "public" = {
            "path" = "/mnt/hdd1/shares/public";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "yes";
            "create mask" = "0666";
            "directory mask" = "0777";
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
          "paperless_consume" = {
            "path" = "/mnt/hdd1/shares/paperless_consume";
            "browseable" = "yes";
            "read only" = "no";
            "guest ok" = "no";
            "create mask" = "0666";
            "directory mask" = "0755";
            "valid users" = "${config.tarow.facts.username}, hermann";
            "force user" = config.tarow.facts.username;
            "force group" = config.tarow.facts.username;
          };
        }
        // ([config.tarow.facts.username "hermann"]
          |> map (user:
            lib.nameValuePair user {
              "path" = "/mnt/hdd1/shares/${user}";
              "browseable" = "yes";
              "read only" = "no";
              "guest ok" = "no";
              "create mask" = "0644";
              "directory mask" = "0755";
              "force user" = user;
              "force group" = user;
              "valid users" = user;
            })
          |> lib.listToAttrs);
    };
  };

  users.groups."hermann".gid = 1001;

  users.users."hermann" = {
    isNormalUser = true;
    description = "hermann";

    uid = 1001;
    group = config.users.groups."hermann".name;

    extraGroups = ["users"];
    shell = pkgs.fish;
    linger = true;
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
      allowedUDPPorts = [9 53 80 443 51820];
      allowedTCPPorts = [21 53 80 443] ++ (lib.range 40000 40009);
    };
    hostName = "relsat";
    defaultGateway = "192.168.178.1";
    nameservers = [defaultGateway "1.1.1.1" "9.9.9.9"];
    resolvconf.extraOptions = ["timeout:2"];

    interfaces.enp3s0 = {
      wakeOnLan.enable = true;
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
        "/mnt/hdd1/shares"
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
        repo = "ssh://u363719@u363719.your-storagebox.de:23/./backups/relsat";
        postHook = "${ping} backup-relsat-remote $exitStatus";
      };
      local = {
        repo = "/mnt/hdd1/backups/relsat";
        postHook = "${ping} backup-relsat-local $exitStatus";
      };
    }
    |> lib.mapAttrs (_: job: (base // job));
}
