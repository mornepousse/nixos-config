{ config, pkgs, inputs, ... }:

{
  # nix-ld pour les binaires non-NixOS (utilitaires divers)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      libusb1
      udev
      ncurses
    ];
  };

  environment.systemPackages = with pkgs; [
    # Outils de base pour ESP-IDF
    git
    wget
    cmake
    ninja
    python3

    # Pour le debug et flash
    openocd
    esptool
    dfu-util

    # Script pour entrer dans l'environnement ESP-IDF
    (pkgs.writeShellScriptBin "esp-shell" ''
      echo "Entering ESP-IDF development environment..."
      exec nix develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf
    '')

    # Script pour lancer VSCode avec l'environnement ESP-IDF
    (pkgs.writeShellScriptBin "code-esp" ''
      echo "Launching VSCode with ESP-IDF environment..."
      nix develop github:mirrexagon/nixpkgs-esp-dev#esp32-idf --command code "$@"
    '')
  ];

  # Permettre l'accès USB sans sudo (ESP32/CH340)
  services.udev.extraRules = ''
    # ESP32 USB-SERIAL-JTAG
    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", MODE="0666"
    # CH340 USB-Serial
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666"
  '';
}
