{
  lib,
  options,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.samba;
in {
  options.tarow.samba = {
    enable = lib.mkEnableOption "Samba";
    extraSettings = options.services.samba.settings;
  };

  config = lib.mkIf cfg.enable {
    services = {
      samba = {
        enable = true;
        openFirewall = true;
        package = pkgs.samba4Full;
        # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
        # Required for samba to register mDNS records for auto discovery
        # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
        settings = lib.mkMerge [
          {
            global = {
              "workgroup" = "WORKGROUP";
              "server string" = "smbnix";
              "netbios name" = "smbnix";
              "security" = "user";

              "guest account" = "nobody";
              "map to guest" = "Bad User";
              "server min protocol" = "SMB3_00";
              "store dos attributes" = "no";
            };
          }
          cfg.extraSettings
        ];
      };
      avahi = {
        publish.enable = true;
        publish.userServices = true;
        # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`

        enable = true;
        openFirewall = true;
      };
      samba-wsdd = {
        # This enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
        enable = true;
        openFirewall = true;
      };
    };

    # Automatically create share directories
    systemd.tmpfiles.rules =
      (builtins.removeAttrs config.services.samba.settings ["global"])
      |> lib.mapAttrsToList (
        name: value: let
          guest =
            if value."guest ok" == "yes"
            then true
            else false;

          path = value."path";
          mask = value."directory mask" or "0755";
          user =
            value."force user" or (
              if guest
              then "nobody"
              else "root"
            );
          group =
            value."force group" or (
              if guest
              then "nogroup"
              else "root"
            );
        in "d ${path} ${mask} ${user} ${group} -"
      );
  };
}
