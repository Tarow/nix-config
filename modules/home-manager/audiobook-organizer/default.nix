{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.tarow.audiobook-organizer;

  version = "0.9.17";
  audiobook-organizer = pkgs.buildGoModule {
    name = "audiobook-organizer";
    pname = "audiobook-organizer";
    version = version;
    src = pkgs.fetchFromGitHub {
      owner = "jeeftor";
      repo = "audiobook-organizer";
      tag = "v${version}";
      hash = "sha256-O6VjMEcGjVhBTSARqyxIE+s6b8Rq9QU4DChSyYI2rQ8=";
    };
    vendorHash = "sha256-zUaRiQKmYPOhCppBQUwlohXpQmpNGwpKcriEwAmM9Sw=";
    meta.mainProgram = "audiobook-organizer";
  };
in {
  options.tarow.audiobook-organizer = {
    enable = lib.options.mkEnableOption "Audiobook-Organizer";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [audiobook-organizer];
  };
}
