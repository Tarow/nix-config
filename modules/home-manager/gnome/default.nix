{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.tarow.gnome;
in {
  options.tarow.gnome = {
    enable = lib.options.mkEnableOption "Gnome";
  };
  config = lib.mkIf cfg.enable {
    dconf.settings = {
      # Set EurKey as Keyboard Layout
      "org/gnome/desktop/input-sources" = {
        show-all-sources = true;
        sources = [
          (lib.hm.gvariant.mkTuple ["xkb" "eu"])
        ];
      };

      # Keyboard Shortcuts
      "org/gnome/shell/keybindings" = {
        show-screenshot-ui = ["<Shift><Super>s"];
      };

      "org/gnome/desktop/wm/keybindings" = {
        switch-windows = ["<Alt>Tab"];
        switch-windows-backward = ["<Shift><Alt>Tab"];
        switch-applications = ["<Super>Tab"];
        switch-applications-backward = ["<Shift><Super>Tab"];
        cycle-group = ["<Super>Escape"];
      };

      "org/gnome/desktop/peripherals/mouse" = {
        # Turn off mouse acceleration
        accel-profile = "flat";
        speed = 0.0;
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
        auto-raise = true;
        focus-new-windows = "smart";
        num-workspaces = 3;
      };

      # Turn screen off after 15 minutes of inactivity
      "org/gnome/desktop/session" = {
        idle-delay = lib.hm.gvariant.mkUint32 900;
      };

      # Hibernate after 1 hour of inactivity
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-timeout = 3600;
        sleep-inactive-ac-type = "suspend";
      };

      # Disable "hot corner"
      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
      };

      # Enable tiling windows on edge
      "org/gnome/mutter" = {
        edge-tiling = true;
      };

      # Favorite apps in bottom bar
      "org/gnome/shell".favorite-apps = [
        (lib.optionalString config.tarow.ghostty.enable "com.mitchellh.ghostty.desktop")
        "org.gnome.Nautilus.desktop"
        "org.gnome.Settings.desktop"
        (lib.optionalString config.programs.firefox.enable "firefox.desktop")
        (lib.optionalString (builtins.elem pkgs.telegram-desktop config.home.packages) "org.telegram.desktop.desktop")
        (lib.optionalString (builtins.elem pkgs.discord config.home.packages) "discord.desktop")
        (lib.optionalString config.programs.vscode.enable "code.desktop")
        (lib.optionalString (builtins.elem pkgs.obsidian config.home.packages) "obsidian.desktop")
        "org.gnome.Calendar.desktop"
      ];

      # Extension settings
      "org/gnome/shell/extensions/pano" = {
        "global-shortcut" = ["<Control><Alt>v"];
        "play-audio-on-copy" = false;
        "send-notification-on-copy" = false;
      };
    };

    # Install & enable extensions
    programs.gnome-shell = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [
        {package = blur-my-shell;}
        {package = vitals;}
        {package = caffeine;}
        {package = pano;}
      ];
    };

    # GNOME does not see new applications installed with HM unless until next login.
    # Workaround to make GNOME find applications without needing to relogin again
    # See https://github.com/NixOS/nixpkgs/issues/12757#issuecomment-2253490852
    home.activation.copyDesktopFiles = lib.hm.dag.entryAfter ["installPackages"] ''
      if [ -d "${config.home.homeDirectory}/.nix-profile/share/applications" ]; then
        run rm -rf ${config.home.homeDirectory}/.local/share/applications
        run mkdir -p ${config.home.homeDirectory}/.local/share/applications
        for file in ${config.home.homeDirectory}/.nix-profile/share/applications/*; do
          run ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
        done
      fi
    '';
  };
}
