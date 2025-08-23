{
  lib,
  config,
  ...
}: let
  cfg = config.tarow.podman;
in {
  options.tarow.podman.enable = lib.options.mkEnableOption "Podman";

  config = lib.mkIf cfg.enable {
    services.podman.enable = true;

    programs.fish.shellAbbrs = {
      pl = "podman logs";
      plf = "podman logs -f";
      psh = {
        expansion = "podman exec -it % /bin/sh";
        setCursor = true;
      };
      prun = {
        expansion = "podman run --rm -it % /bin/sh";
        setCursor = true;
      };
    };
  };
}
