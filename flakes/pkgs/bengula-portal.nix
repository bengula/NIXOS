# Reproducible Nix build of the Bengula Inc portal.
#
# The project builds in two steps (see its package.json "build" script):
#   1. `vite build`   -> static client assets in dist/
#   2. `esbuild ...`  -> dist/server.cjs (the Express server, deps left EXTERNAL)
#
# Because esbuild bundles with `--packages=external`, the server still needs
# node_modules at runtime, so we keep a pruned (prod-only) node_modules in the
# output and run it with `node dist/server.cjs`.
{ lib, buildNpmPackage, nodejs_20, makeWrapper, src }:

buildNpmPackage {
  pname = "bengula-portal";
  version = "0.0.0";

  inherit src;

  # Use the same Node major version as the dev shell / system package.
  nodejs = nodejs_20;

  # For the bin/ wrapper created in installPhase.
  nativeBuildInputs = [ makeWrapper ];

  # ── npmDepsHash ───────────────────────────────────────────────────────────
  # This MUST match the project's package-lock.json. It cannot be computed on
  # the machine authoring this file — derive it on a Nix host:
  #   1. Leave the fake hash below in place.
  #   2. Run the rebuild; Nix will fail and print the correct `got: sha256-…`.
  #   3. Paste that value here and rebuild again.
  # (Alternatively: `nix run nixpkgs#prefetch-npm-deps -- path/to/package-lock.json`)
  npmDepsHash = lib.fakeHash;

  # Runs `npm run build` (vite build + esbuild) during buildPhase.
  npmBuildScript = "build";

  # Custom install: this is an app, not a publishable library, so we place the
  # built server + assets + prod deps under $out/lib/bengula-portal.
  installPhase = ''
    runHook preInstall

    # Drop devDependencies now that the build is done.
    npm prune --omit=dev

    mkdir -p $out/lib/bengula-portal
    cp -r dist node_modules package.json $out/lib/bengula-portal/

    # Wrapper entrypoint. The server reads its static `dist/` relative to the
    # process CWD and only serves the production build when NODE_ENV=production,
    # so the wrapper pins both. PORT is supplied by the runtime environment.
    makeWrapper ${nodejs_20}/bin/node $out/bin/bengula-portal \
      --add-flags "$out/lib/bengula-portal/dist/server.cjs" \
      --chdir "$out/lib/bengula-portal" \
      --set NODE_ENV production

    runHook postInstall
  '';

  meta = {
    description = "Bengula Inc portal — Vite static client served by an Express server";
    mainProgram = "bengula-portal";
    platforms = lib.platforms.linux;
  };
}
