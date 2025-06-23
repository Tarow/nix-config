{
  config,
  lib,
  pkgs,
  ...
}: let
  name = "crowdsec";
  storage = "${config.tarow.stacks.storageBaseDir}/${name}";
  cfg = config.tarow.stacks.${name};

  yaml = pkgs.formats.yaml {};

  timer = {
    Timer = {
      OnCalendar = "01:30";
      Persistent = true;
    };
    Install = {
      WantedBy = ["timers.target"];
    };
  };
  job = {
    Service = {
      Type = "oneshot";
      ExecStart = lib.getExe (
        pkgs.writeShellScriptBin "crowdsec-update"
        ([
            "hub update"
            "hub upgrade"
            "collections upgrade -a"
            "parsers upgrade -a"
            "scenarios upgrade -a"
          ]
          |> lib.concatMapStringsSep "\n" (c: "${lib.getExe pkgs.podman} exec ${name} cscli " + c))
      );
    };
  };
in {
  options.tarow.stacks.${name} = {
    enable = lib.mkEnableOption name;
    acquisSettings = lib.mkOption {
      type = yaml.type;
      default = import ./acquis.nix;
      description = "Acquisitions settings for Crowdsec.";
      apply = yaml.generate "acquis.yaml";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      timers."crowdsec-upgrade" = timer;
      services."crowdsec-upgrade" = job;
    };

    services.podman.containers.${name} = {
      image = "docker.io/crowdsecurity/crowdsec:latest";
      volumes = [
        "${storage}/db:/var/lib/crowdsec/data"
        "${storage}/config:/etc/crowdsec"
        "${cfg.acquisSettings}:/etc/crowdsec/acquis.yaml"
        "${config.tarow.podman.socketLocation}:/var/run/docker.sock:ro"
      ];
      environment = {
        COLLECTIONS = "crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/whitelist-good-actors";
        UID = config.tarow.stacks.defaultUid;
        GID = config.tarow.stacks.defaultGid;
      };
      environmentFile = [config.sops.secrets."crowdsec/env".path];
      network = lib.optional config.tarow.stacks.traefik.enable config.tarow.stacks.traefik.network;

      homepage = {
        category = "Network & Administration";
        name = "Crowdsec";
        settings = {
          description = "Adblocker";
          icon = "crowdsec";
        };
      };
    };
  };
}
