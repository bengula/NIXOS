# Orbit Wallpaper Engine — a Wayland GLSL shader wallpaper renderer.
#
# https://github.com/CleanShirtUK/orbit-wallpaper-engine  (GPL-3.0-or-later)
#
# `src` is passed in from the flake input, so the revision is pinned in
# flake.lock and there is no hash to keep in sync here.
{
  lib,
  stdenv,
  pkg-config,
  wayland,
  libGL,
  libpng,
  src,
  version ? "0-unstable",
}:

stdenv.mkDerivation {
  pname = "orbit-wallpaper-engine";
  inherit version src;

  nativeBuildInputs = [ pkg-config ];

  # wayland  → libwayland-client, libwayland-egl
  # libGL    → libEGL, libGLESv2
  # libpng   → libpng16
  buildInputs = [
    wayland
    libGL
    libpng
  ];

  # Upstream hardcodes Fedora's libpng include path (-I/usr/include/libpng16).
  # Every flag in the Makefile uses `?=`, so a command-line assignment wins;
  # the headers come from buildInputs instead.
  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CPPFLAGS=-DWITH_GZFILEOP"
  ];

  # `make install` writes into $HOME and drops a systemd unit into
  # ~/.config/systemd/user. Home Manager owns both of those, so install by hand
  # and let the module place the runtime files.
  installPhase = ''
    runHook preInstall

    install -Dm755 orbit-wallpaper-engine -t "$out/bin"
    install -Dm644 wave.frag -t "$out/share/orbit-wallpaper-engine"
    install -Dm644 orbit-wallpaper-engine.conf -t "$out/share/orbit-wallpaper-engine"

    runHook postInstall
  '';

  meta = {
    description = "Wayland shader wallpaper renderer with intro/exit animation control";
    homepage = "https://github.com/CleanShirtUK/orbit-wallpaper-engine";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "orbit-wallpaper-engine";
  };
}
