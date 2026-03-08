{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.cachix;
in {
  options.tarow.cachix = {
    enable = lib.options.mkEnableOption "Cachix";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        extra-substituters = [
          "https://tarow.cachix.org"
        ];
        extra-trusted-public-keys = [
          "tarow.cachix.org-1:qn8zPR5EW/6IEEkbX3/cIrNP8BhS0Baj4AdDHaYnxzk="
        ];
      };
    };
  };
}
