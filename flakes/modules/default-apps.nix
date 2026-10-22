# Which app opens what, and where the user directories are.
#
# Under GNOME this is set by clicking through "Open With" once and forgetting
# about it; the answers live in ~/.config/mimeapps.list, which nothing in this
# flake owned. Two of the handlers in the hand-written file had rotted:
# application/pdf pointed at org.gnome.Evince.desktop (Evince is now Papers,
# so opening a PDF did nothing) and mailto at chromium-browser.desktop (not
# installed). Both are fixed below.
#
# IMPORTANT: once `xdg.mimeApps.enable` is on, this file *is* the whole
# mimeapps.list — Nix rewrites it and GNOME's "Set as default" button no
# longer sticks across a rebuild. So every handler that used to be in there by
# hand is repeated here, scheme handlers included; the previous file is kept as
# ~/.config/mimeapps.list.hm-bak on the first rebuild if anything is missed.
#
# `xdg.userDirs` is here rather than in its own file because it is the same
# concern seen from the other side — ./hyprland-keys.nix reads
# $XDG_PICTURES_DIR to decide where screenshots go, and ./record.nix reads
# $XDG_VIDEOS_DIR; both were falling back to a hardcoded $HOME path because
# nothing generated ~/.config/user-dirs.dirs.
{
  flake.modules.homeManager.default-apps =
    { ... }:
    let
      browser = [ "google-chrome.desktop" ];
      images = [ "org.gnome.Loupe.desktop" ];
      # VLC handles the formats GNOME's own players refuse, and it is now
      # installed for every user (see ./packages.nix).
      media = [ "vlc.desktop" ];
      # Prose and plain text keep the editor that was already chosen for them;
      # code goes to VSCodium, which nothing had claimed.
      text = [ "org.gnome.TextEditor.desktop" ];
      code = [ "codium.desktop" ];
      pdf = [ "org.gnome.Papers.desktop" ];
      files = [ "org.gnome.Nautilus.desktop" ];
      mail = [ "thunderbird.desktop" ];
      telegram = [ "org.telegram.desktop.desktop" ];
      signal = [ "signal.desktop" ];
      gsconnect = [ "org.gnome.Shell.Extensions.GSConnect.desktop" ];
    in
    {
      xdg.mimeApps = {
        enable = true;

        # [Default Applications] — the answer to "open this".
        defaultApplications = {
          # Web
          "text/html" = browser;
          "application/xhtml+xml" = browser;
          "x-scheme-handler/http" = browser;
          "x-scheme-handler/https" = browser;
          "x-scheme-handler/about" = browser;
          "x-scheme-handler/unknown" = browser;

          # Documents
          "application/pdf" = pdf;
          "text/plain" = text;
          "text/markdown" = text;
          "text/csv" = text;
          "text/x-tex" = text;

          # Code
          "application/json" = code;
          "text/x-python" = code;
          "application/x-shellscript" = code;
          "text/x-c" = code;
          "application/x-yaml" = code;

          # Images
          "image/png" = images;
          "image/jpeg" = images;
          "image/gif" = images;
          "image/webp" = images;
          "image/svg+xml" = images;
          "image/bmp" = images;
          "image/tiff" = images;

          # Audio & video
          "video/mp4" = media;
          "video/x-matroska" = media;
          "video/webm" = media;
          "video/quicktime" = media;
          "video/x-msvideo" = media;
          "video/mpeg" = media;
          "audio/mpeg" = media;
          "audio/flac" = media;
          "audio/x-wav" = media;
          "audio/ogg" = media;
          "audio/mp4" = media;

          "inode/directory" = files;

          # The budget files in ~/Documents/budget. HomeBank's own desktop
          # file already claims this type, so it worked without mimeapps.list
          # — it is named here because the hand-written file had
          # `application/x-trash=homebank.desktop` instead, which is a
          # different type that nothing on this machine produces. Verified
          # with `xdg-mime query filetype Documents/budget/bengula.xhb`.
          "application/x-homebank" = [ "homebank.desktop" ];

          # ── App URL schemes ─────────────────────────────────────────────
          # These are the ones that have to survive this file being generated:
          # a missing handler here means a link that silently does nothing.
          "x-scheme-handler/mailto" = mail;
          "x-scheme-handler/tg" = telegram;
          "x-scheme-handler/tonsite" = telegram;
          "x-scheme-handler/sgnl" = signal;
          "x-scheme-handler/signalcaptcha" = signal;
          "x-scheme-handler/sms" = gsconnect;
          "x-scheme-handler/tel" = gsconnect;
          "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
        };

        # [Added Associations] — the extra entries in the "Open With" menu,
        # without changing which one is the default.
        associations.added = {
          "text/markdown" = [
            "obsidian.desktop"
            "codium.desktop"
          ];
          "text/plain" = [ "codium.desktop" ];
          "text/x-tex" = [ "codium.desktop" ];
          "application/pdf" = browser;
        };
      };

      xdg.userDirs = {
        enable = true;

        # The directories below all already exist; this only names them, so
        # nothing is moved or created behind your back.
        createDirectories = false;

        desktop = "$HOME/Desktop";
        documents = "$HOME/Documents";
        download = "$HOME/Downloads";
        music = "$HOME/Music";
        pictures = "$HOME/Pictures";
        publicShare = "$HOME/Public";
        templates = "$HOME/Templates";
        videos = "$HOME/Videos";

        # Home Manager has a first-class option for this one, and its default
        # is already ~/Projects — named here only so the whole set is visible
        # in one place.
        projects = "$HOME/Projects";
      };
    };
}
