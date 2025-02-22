{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.soundblaster;
in {
  options.tarow.soundblaster = {
    enable = lib.options.mkEnableOption "Soundblaster";
    deviceID = lib.options.mkOption {
      type = lib.types.str;
      default = "hw:G6";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.soundblaster-set-alsa-options = {
      path = with pkgs; [coreutils-full alsa-utils];
      script = [
        "'PCM Capture Source' 'External Mic'"
        "'External Mic',0 Capture cap"
        "'External Mic',0 Capture 9dB"
        "'Line In',0 Capture nocap"
        "'S/PDIF In',0 Capture nocap"
        "'What U Hear',0 Capture nocap"

        "'Line In',0 Playback mute"
        "'External Mic',0 Playback mute"
        "'S/PDIF In',0 Playback mute"
      ] 
      |> builtins.map (cmd: "amixer -D ${cfg.deviceID} sset ${cmd}")
      |> builtins.concatStringsSep "\n";
      # Wait until wireplumber has set the alsa options.
      preStart = "sleep 5";
      # pipewire.service reached on initial startup sound.target is reached on subsequent soundcard events
      wantedBy = ["sound.target" "pipewire.service"];
      after = ["pipewire.service" "wireplumber.service"];
      serviceConfig = {Type = "oneshot";};
    };
  };
}
