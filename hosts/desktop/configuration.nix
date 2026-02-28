# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.11";

  tarow = lib.mkMerge [
    (lib.tarow.enableModules [
      "core"
      "bootLoader"
      "gaming"
      "gnome"
      "docker"
      "keyboard"
      "locale"
      "networkManager"
      "nh"
      "pipewire"
      "printing"
      "shells"
      "sops"
      "stylix"
      "oomd"
    ])
    {facts.ip4Address = "10.1.1.210";}

    {monitors.configuration = ./monitors.xml;}
    {
      sops.extraSopsFiles = [../../secrets/desktop/secrets.yaml];
    }
  ];

  networking.hostName = "nixos";

  nix.settings.trusted-users = ["@wheel"];

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # Prevent instant wakeup from suspend
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
    }
  ];

  # Workaround for
  # https://github.com/NixOS/nixpkgs/issues/103746
  # https://discourse.nixos.org/t/gnome-display-manager-fails-to-login-until-wi-fi-connection-is-established/50513/11
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  boot.loader.systemd-boot = {
    windows."win11" = {
      title = "Windows 11";
      efiDeviceHandle = "HD0b";
      sortKey = "z0";
    };
    edk2-uefi-shell = {
      enable = true;
      sortKey = "z1";
    };
  };
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "windows" ''
      set -euo pipefail
      bootctl set-oneshot windows_win11.conf
      bootctl set-timeout-oneshot 1
      reboot
    '')
  ];

  # Necessary for file browsers to browse samba shares
  services.gvfs.enable = true;

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = lib.mkForce 0;
  networking.firewall.allowedUDPPorts = [80 443 51820];
  networking.firewall.allowedTCPPorts = [80 443];

  services.borgbackup.jobs = {
    remote = {
      paths = [
        "/home/niklas/stacks"
      ];

      repo = "ssh://u363719@u363719.your-storagebox.de:23/./backups/desktop";
      encryption = {
        mode = "repokey-blake2";
        passCommand = "cat ${config.sops.secrets."borg/passphrase".path}";
      };
      compression = "auto,lzma";
      startAt = "daily";
    };
  };
}
