{ config, pkgs, ... }:

{
  imports = [ ./terminal.nix ];

  home.username = "bebe";
  home.homeDirectory = "/home/bebe";
  home.stateVersion = "25.11";
  
 # This enables the 'home-manager' command in your shell
  programs.home-manager.enable = true; 
  
  programs.git = {
    enable = true;
    settings = {
      user = {
        name  = "Bengula Jacob";
        email = "kbengula@student.maseno.ac.ke";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.fish.enable = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.neovim.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    gnome-extension-manager
    homebank
    fd
    ripgrep
    eza
    # Cheatsheet: Super+/ opens this in wofi
    (writeShellScriptBin "hypr-keybinds" ''
      set -euo pipefail
      mkdir -p "$HOME/Pictures"
      ${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt "Hyprland shortcuts" \
        --width 720 --height 520 --cache-file /dev/null <<'EOF'
      Super + /                 Show this shortcuts list
      Super + Return            Open terminal (GNOME Console)
      Super + D                 App launcher (wofi)
      Super + E                 File manager (Nautilus)
      Super + Q                 Close focused window
      Super + F                 Toggle fullscreen
      Super + V                 Toggle floating
      Super + P                 Pseudo-tile
      Super + T                 Toggle split direction
      Super + Escape            Lock screen
      Super + R                 Reload Hyprland config
      Super + M                 Exit Hyprland
      Super + Tab               Next workspace
      Super + Shift + Tab       Previous workspace
      Super + h/j/k/l           Focus left/down/up/right
      Super + Arrows            Focus in that direction
      Super + Shift + h/j/k/l   Move window left/down/up/right
      Super + Shift + Arrows    Move window in that direction
      Super + Ctrl + h/j/k/l    Resize window
      Super + 1…0               Switch to workspace 1–10
      Super + Shift + 1…0       Move window to workspace 1–10
      Super + S                 Toggle special (scratch) workspace
      Super + Shift + S         Move window to special workspace
      Super + mouse LMB drag    Move window
      Super + mouse RMB drag    Resize window
      Print                     Screenshot full screen → ~/Pictures
      Super + Print             Screenshot region → ~/Pictures
      Volume / mute keys        Raise, lower, mute audio
      Brightness keys           Raise / lower brightness
      EOF
    '')
  ];

  # Minimal lock screen (Super + Escape)
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [
        {
          monitor = "";
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "280, 48";
          position = "0, -40";
          halign = "center";
          valign = "center";
          placeholder_text = "Password…";
          fade_on_empty = false;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 64;
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Monitor — auto-detect; adjust if needed e.g. "DP-1,1920x1080@60,0x0,1"
      monitor = ",preferred,auto,1";

      # Autostart
      exec-once = [
        "waybar"
        "hyprpaper"
        "dunst"
        "mkdir -p ~/Pictures"
      ];

      # Environment
      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORM,wayland"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(88c0d0ff) rgba(81a1c1ff) 45deg";
        "col.inactive_border" = "rgba(4c566aff)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Keybindings — SUPER is the Windows/Meta key
      "$mod" = "SUPER";
      bind = [
        # Apps & session
        "$mod, Return, exec, gnome-terminal"
        "$mod, D, exec, wofi --show drun"
        "$mod, E, exec, nautilus"
        "$mod, Q, killactive"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        "$mod, P, pseudo"
        "$mod, T, togglesplit"
        "$mod, Escape, exec, hyprlock"
        "$mod, R, exec, hyprctl reload"
        "$mod, M, exit"
        "$mod, slash, exec, hypr-keybinds"

        # Focus — arrows + vim keys
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Move windows
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        # Resize windows
        "$mod CTRL, left,  resizeactive, -40 0"
        "$mod CTRL, right, resizeactive, 40 0"
        "$mod CTRL, up,    resizeactive, 0 -40"
        "$mod CTRL, down,  resizeactive, 0 40"
        "$mod CTRL, h, resizeactive, -40 0"
        "$mod CTRL, j, resizeactive, 0 40"
        "$mod CTRL, k, resizeactive, 0 -40"
        "$mod CTRL, l, resizeactive, 40 0"

        # Workspaces 1–10
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

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Cycle workspaces + scratchpad
        "$mod, Tab, workspace, e+1"
        "$mod SHIFT, Tab, workspace, e-1"
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        # Screenshots
        ", Print, exec, mkdir -p ~/Pictures && grim ~/Pictures/screenshot-$(date +%F_%T).png"
        "$mod, Print, exec, mkdir -p ~/Pictures && grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%F_%T).png"

        # Media keys
        ", XF86AudioRaiseVolume,  exec, pamixer -i 5"
        ", XF86AudioLowerVolume,  exec, pamixer -d 5"
        ", XF86AudioMute,         exec, pamixer -t"
        ", XF86MonBrightnessUp,   exec, brightnessctl set 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}

