# The flake-parts skeleton. Everything else in this directory is an aspect.
{ inputs, ... }:

{
  imports = [
    # Declares the `flake.modules.<class>.<name>` option — the shared namespace
    # that every other file in this tree writes into. Without this import,
    # `flake.modules.nixos.foo` would be an unknown option.
    inputs.flake-parts.flakeModules.modules
  ];

  systems = [ "x86_64-linux" ];
}
