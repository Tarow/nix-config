{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.tarow.git-clone;
  repoType =
    types.submodule
    ({name, ...}: {
      options = {
        enable = mkOption {
          type = types.bool;
          default = true;
          example = true;
          description = "If the repository should be cloned. If false, the repo will be deleted if it exists.";
        };
        location = mkOption {
          type = types.str;
          default = cfg.defaultLocation;
          example = "$HOME/projects";
          apply = s: builtins.replaceStrings ["~"] ["$HOME"] s;
          description = "Target directory of the repo.";
        };
        uri = mkOption {
          type = types.str;
          example = "https://github.com/someuser/somerepo";
          description = "URI of the repository to be cloned";
        };
      };
    });
in {
  options.tarow.git-clone = {
    defaultLocation = mkOption {
      type = types.str;
      example = "$HOME/projects";
      apply = s: builtins.replaceStrings ["~"] ["$HOME"] s;
      description = "Default target location to clone repositories into, if no explicit location is set for an repository";
    };
    repos = mkOption {
      type = with types; attrsOf repoType;
      default = {};
      description = ''
        The repositories that should be cloned if they don't exist yet.
      '';
    };
  };

  config = lib.mkIf (cfg.repos != {}) {
    home.extraActivationPath = with pkgs; [git openssh];
    home.activation.git-repos =
      hm.dag.entryAfter ["writeBoundary"]
      (concatStringsSep "\n"
        (mapAttrsToList
          (
            name: repo: (
              let
                dir = builtins.replaceStrings ["//"] ["/"] "${repo.location}/${name}";
              in
                if repo.enable
                then ''run [ -d "${dir}" ] || git clone "${repo.uri}" "${dir}" ''
                else ''run rm -rf "${dir}" ''
            )
          )
          cfg.repos));
  };
}
