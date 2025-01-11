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
      #"hyprland"
      "keyboard"
      "locale"
      "networkManager"
      "pipewire"
      "printing"
      "shells"
      "soundblaster"
      "stylix"
    ])
    {core.configLocation = "~/nix-config#desktop";}
    {monitors.configuration = ./monitors.xml;}
  ];

  networking.hostName = "nixos";
  users.users.niklas = {
    isNormalUser = true;
    description = "Niklas";
    extraGroups = ["wheel" (lib.mkIf config.tarow.networkManager.enable "networkmanager")];
    shell = pkgs.fish;
  };
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
    powerManagement.enable = false;

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
    package = config.boot.kernelPackages.nvidiaPackages.stable;
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
    edk2-uefi-shell.enable = true;
    windows."win11" = {
      title = "Windows 11";
      efiDeviceHandle = "HD0b";
      sortKey = "z_windows";
    };
  };

  # Necessary for file browsers to browse samba shares
  services.gvfs.enable = true;
}
