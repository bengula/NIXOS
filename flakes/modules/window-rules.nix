# Window rules — the layout's exceptions.
#
# Nothing here is cosmetic: dwindle tiles *everything* by default, so a GTK
# "Save as" dialog or a volume mixer became a tile and shoved the window it
# belongs to aside. Floating those is the bulk of the file.
#
# Rules are hand-written Lua for the same reason as the keybinds — see the
# long note in ./desktop-hyprland.nix. The spelling of a rule's fields is
# snake_case and *checked*: `hl.window_rule` rejects an unknown field outright
# (`no_border` is not one, for instance — it is `border_size = 0`), so a typo
# aborts the Lua chunk and takes every rule after it down with it. Verify a
# new one live before committing it:
#
#   hyprctl eval 'hl.window_rule({ name = "probe", match = { class = "^(x)$" }, … })'
#
# Window classes are what the app reports, not what it is called. Check with:
#
#   hyprctl clients -j | jq -r '.[] | "\(.class)\t\(.title)"'
{
  flake.modules.homeManager.window-rules = {
    wayland.windowManager.hyprland.extraConfig = ''
      -- ── Global behaviour ────────────────────────────────────────────────
      -- Apps asking to be maximised get ignored; under a tiling layout
      -- "maximised" is already the normal state and the request only confuses
      -- the layout.
      hl.window_rule({
        name = "suppress-maximize",
        match = { class = ".*" },
        suppress_event = "maximize",
      })

      -- Keep the screen awake while something is fullscreen. hypridle dims at
      -- 5 minutes and locks at 10 (./lock.nix), which is the wrong answer
      -- halfway through a film. Scoped to fullscreen rather than to the video
      -- players by class, so it covers fullscreen video in a browser too —
      -- and so a paused, windowed player does not hold the lock off forever.
      hl.window_rule({
        name = "idle-inhibit-fullscreen",
        match = { class = ".*" },
        idle_inhibit = "fullscreen",
      })

      -- XWayland drag-and-drop sends a zero-size, classless, titleless window
      -- that must never take focus, or the drag is dropped the moment it
      -- starts. Taken from Hyprland's own shipped example config.
      hl.window_rule({
        name = "fix-xwayland-drags",
        match = {
          class = "^$",
          title = "^$",
          xwayland = true,
          float = true,
          fullscreen = false,
          pin = false,
        },
        no_focus = true,
      })

      -- ── Dialogs ─────────────────────────────────────────────────────────
      -- The GTK file chooser, which every browser, Obsidian and VSCodium all
      -- open. Matched by title because the chooser is a window of the parent
      -- app and carries the parent's class.
      hl.window_rule({
        name = "float-file-chooser",
        match = { title = "^(Open|Open File|Open Files|Open Folder|Save|Save As|Save File|Select a File|Choose wallpaper|Choose Files)$" },
        float = true,
        center = true,
        size = "70% 70%",
      })

      -- Small single-purpose windows that have no business being tiled.
      hl.window_rule({
        name = "float-utilities",
        match = { class = "^([Pp]avucontrol|blueman-manager|nm-connection-editor|org\\.gnome\\.Calculator|org\\.gnome\\.FileRoller|gnome-disks|udiskie|file-roller|\\.blueman-manager-wrapped)$" },
        float = true,
        center = true,
        size = "50% 55%",
      })

      -- Permission and portal prompts: the polkit agent from ./polkit.nix and
      -- the screen-share picker from ./portals.nix.
      hl.window_rule({
        name = "float-prompts",
        match = { class = "^(org\\.freedesktop\\.impl\\.portal\\.desktop\\.[a-z]+|hyprpolkitagent|polkit-gnome-authentication-agent-1|xdg-desktop-portal-gtk)$" },
        float = true,
        center = true,
      })

      -- ── Media ───────────────────────────────────────────────────────────
      -- Picture-in-Picture parks itself bottom-right, stays on top of
      -- everything and follows you between workspaces.
      hl.window_rule({
        name = "pip",
        match = { title = "^(Picture[- ]in[- ][Pp]icture)$" },
        float = true,
        pin = true,
        size = "26% 26%",
        move = "72% 70%",
      })

      -- Video should be the colour it actually is: no dimming from the
      -- inactive-window dim, and fully opaque whether focused or not.
      hl.window_rule({
        name = "video-opaque",
        match = { class = "^([Vv]lc|mpv|io\\.github\\.celluloid|org\\.gnome\\.Decibels)$" },
        opacity = "1.0 1.0",
        no_dim = true,
      })

      -- ── Where things open ───────────────────────────────────────────────
      -- "silent" is the whole point: the window goes to its workspace without
      -- dragging you there, so launching Spotify mid-task does not move you.
      hl.window_rule({
        name = "spotify-to-9",
        match = { class = "^([Ss]potify)$" },
        workspace = "9 silent",
      })

      hl.window_rule({
        name = "chat-to-8",
        match = { class = "^([Dd]iscord|[Ss]ignal|org\\.telegram\\.desktop|teams-for-linux)$" },
        workspace = "8 silent",
      })
    '';
  };
}
