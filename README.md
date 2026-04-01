# Erudite NixOS Configuration

This repository contains a modular NixOS configuration managed with Nix Flakes and Home Manager.

## Repository Structure

The configuration is organized modularly to ensure maintainability and reproducibility:

- **`flakes/`**: The root directory for the Nix flake configuration.
  - **`flake.nix`**: Entry point for the system configuration. It defines the inputs (nixpkgs, home-manager) and the `Erudite` host output.
  - **`hosts/`**: Host-specific configurations.
    - **`erudite/`**: Configuration for the "Erudite" host.
      - `default.nix`: Main host configuration, including hostname and state version.
      - `hardware.nix`: Hardware-specific configuration, defining file systems and kernel modules.
  - **`modules/`**: Shared system modules imported by the host configuration.
    - `boot.nix`: Bootloader configuration using GRUB with OS prober enabled.
    - `desktop-gnome.nix`: GNOME desktop environment setup, including GDM and PipeWire audio.
    - `home-manager.nix`: Integration of Home Manager into the NixOS system.
    - `locale.nix`: Localization settings, including timezone (`Africa/Nairobi`) and UTF-8 locale.
    - `networking.nix`: NetworkManager configuration and custom DNS servers.
    - `nix.nix`: Nix package manager settings, experimental features (flakes), and automatic garbage collection.
    - `packages.nix`: System-wide package declarations and font configurations.
    - `users.nix`: User account definitions for `lovelty` and `bebe`.
  - **`home/`**: User-specific Home Manager configurations.
    - `bebe.nix`: Detailed user environment for `bebe`, including Fish shell, Starship prompt, and user-specific packages.
    - `lovelty.nix`: Environment for user `lovelty`.

## System Highlights

- **Hostname**: `Erudite`
- **Desktop Environment**: GNOME 4x
- **Shell**: Fish (configured via Home Manager)
- **Bootloader**: GRUB (legacy/BIOS support on `/dev/sda`)
- **Users**:
  - **lovelty** (Winnie Jacob)
  - **bebe** (Happy Home)
- **Key Applications**:
  - **Development**: VS Codium, Python 3, TeX Live Full, Neovim
  - **Productivity**: LibreOffice, Obsidian
  - **Browsers**: Google Chrome, Firefox
  - **Communication**: Microsoft Teams, Spotify, Discord, Telegram, Signal

## Usage

To apply this configuration, ensure you have Nix installed with flakes enabled, then run:

```bash
sudo nixos-rebuild switch --flake ./flakes#Erudite
```

### Maintenance Commands

- **Update Flake Inputs**:
  ```bash
  nix flake update ./flakes
  ```
- **Check Flake Validity**:
  ```bash
  nix flake check ./flakes
  ```
- **Garbage Collection**:
  System garbage collection is automated to run daily at 03:15, removing generations older than 21 days.
