{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.tarow.hyprland;
in {
  options.tarow.hyprland = {
    enable = lib.options.mkEnableOption "Hyprland";
  };

  config = lib.mkIf cfg.enable {
    programs.hyprlock.enable = true;
    home.packages = with pkgs; [walker];
    wayland.windowManager.hyprland = {
      enable = true;
      # https://wiki.hyprland.org/Useful-Utilities/Systemd-start/#uwsm
      # Disable systemd integration since it conflicts with UWSM enabled in the NixOS module
      systemd.enable = false;
      settings = {
        "$mod" = "SUPER";
        "$terminal" = "ghostty";

        exec-once = [];

        bind = [
          # General
          "$mod, return, exec, $terminal"
          "$mod SHIFT, q, killactive"
          "$mod SHIFT, e, exit"
          "$mod SHIFT, l, exec, hyprlock"

          # Screen focus
          "$mod, v, togglefloating"
          "$mod, u, focusurgentorlast"
          "$mod, tab, focuscurrentorlast"
          "$mod, f, fullscreen"

          # Screen resize
          "$mod CTRL, h, resizeactive, -20 0"
          "$mod CTRL, l, resizeactive, 20 0"
          "$mod CTRL, k, resizeactive, 0 -20"
          "$mod CTRL, j, resizeactive, 0 20"

          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspaces
          "$mod SHIFT, 1, movetoworkspace,1"
          "$mod SHIFT, 2, movetoworkspace,2"
          "$mod SHIFT, 3, movetoworkspace,3"
          "$mod SHIFT, 4, movetoworkspace,4"
          "$mod SHIFT, 5, movetoworkspace,5"
          "$mod SHIFT, 6, movetoworkspace,6"
          "$mod SHIFT, 7, movetoworkspace,7"
          "$mod SHIFT, 8, movetoworkspace,8"
          "$mod SHIFT, 9, movetoworkspace,9"
          "$mod SHIFT, 0, movetoworkspace,10"

          # Navigation
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"
        ];

        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        general = {
          gaps_in = 6;
          gaps_out = 6;
          border_size = 2;
          layout = "dwindle";
          allow_tearing = true;
        };

        input = {
          kb_layout = "eu";
          follow_mouse = true;
          touchpad = {
            natural_scroll = true;
          };
          accel_profile = "flat";
          sensitivity = 0;
        };

        decoration = {
          rounding = 15;
          active_opacity = 0.9;
          inactive_opacity = 0.8;
          fullscreen_opacity = 0.9;

          blur = {
            enabled = true;
            xray = true;
            special = false;
            new_optimizations = true;
            size = 14;
            passes = 4;
            brightness = 1;
            noise = 0.01;
            contrast = 1;
            popups = true;
            popups_ignorealpha = 0.6;
            ignore_opacity = false;
          };
        };

        animations = {
          enabled = true;
          bezier = [
            "linear, 0, 0, 1, 1"
            "md3_standard, 0.2, 0, 0, 1"
            "md3_decel, 0.05, 0.7, 0.1, 1"
            "md3_accel, 0.3, 0, 0.8, 0.15"
            "overshot, 0.05, 0.9, 0.1, 1.1"
            "crazyshot, 0.1, 1.5, 0.76, 0.92"
            "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
            "menu_decel, 0.1, 1, 0, 1"
            "menu_accel, 0.38, 0.04, 1, 0.07"
            "easeInOutCirc, 0.85, 0, 0.15, 1"
            "easeOutCirc, 0, 0.55, 0.45, 1"
            "easeOutExpo, 0.16, 1, 0.3, 1"
            "softAcDecel, 0.26, 0.26, 0.15, 1"
            "md2, 0.4, 0, 0.2, 1"
          ];
          animation = [
            "windows, 1, 3, md3_decel, popin 60%"
            "windowsIn, 1, 3, md3_decel, popin 60%"
            "windowsOut, 1, 3, md3_accel, popin 60%"
            "border, 1, 10, default"
            "fade, 1, 3, md3_decel"
            "layersIn, 1, 3, menu_decel, slide"
            "layersOut, 1, 1.6, menu_accel"
            "fadeLayersIn, 1, 2, menu_decel"
            "fadeLayersOut, 1, 4.5, menu_accel"
            "workspaces, 1, 7, menu_decel, slide"
            "specialWorkspace, 1, 3, md3_decel, slidevert"
          ];
        };

        cursor = {
          enable_hyprcursor = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
          smart_split = false;
          smart_resizing = false;
        };
      };
    };
  };
}
