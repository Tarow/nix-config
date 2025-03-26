{
  config,
  lib,
  ...
}: {
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
  ];

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
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  time.timeZone = lib.mkDefault "Europe/Berlin";

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking.firewall.allowedUDPPorts = [80 443 51820];
  networking.firewall.allowedTCPPorts = [80 443];
  networking.hostName = "homeserver";

  services.borgbackup.jobs = let
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
      extraCreateArgs = "--stats --progress";

      prune.keep = {
        within = "1d"; # Keep all archives from the last day
        daily = 7;
        weekly = 4;
        monthly = 3;
      };
    };
  in {
    remote.repo = "ssh://u363719@u363719.your-storagebox.de:23/./backups/homeserver";
    local.repo = "/mnt/hdd1/backups/homeserver";
  } |> lib.mapAttrs (_: job: (base // job));

  system.stateVersion = "24.11";
}
