{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Rust toolchain via overlay (stable + rust-analyzer)
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      targets = [
        "x86_64-unknown-linux-gnu"
        # Décommenter pour cross-compile ESP32 (Xtensa non supporté par rustup standard)
        # Utiliser esp-rs/rust-build pour ESP32 Xtensa
        # "riscv32imc-unknown-none-elf"  # Pour ESP32-C3 (RISC-V)
      ];
    })
    cargo-edit        # cargo add/rm/upgrade
    cargo-watch       # Recompilation auto sur changement

    # Slint
    slint-lsp         # Language server pour éditeurs

    # Dépendances build Slint (backend Winit + renderer Femtovg)
    cmake
    pkg-config
    fontconfig
    freetype
    libxkbcommon
    libGL

    # Backend Wayland (recommandé sur NixOS/Hyprland)
    wayland
    wayland-protocols
    wayland-scanner

    # Backend X11 (fallback)
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi

    # Communication série (microcontrôleurs)
    # serialport-rs utilise libudev
    udev
  ];

  # Variables d'environnement pour que les crates Rust trouvent les libs
  environment.sessionVariables = {
    # pkg-config doit trouver les .pc des dépendances
    PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [
      pkgs.fontconfig.dev
      pkgs.freetype.dev
      pkgs.libxkbcommon.dev
      pkgs.wayland.dev
      pkgs.libGL.dev
    ];

    # Linker doit trouver les .so
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.fontconfig
      pkgs.freetype
      pkgs.libxkbcommon
      pkgs.libGL
      pkgs.wayland
      pkgs.xorg.libX11
      pkgs.xorg.libXcursor
      pkgs.xorg.libXrandr
      pkgs.xorg.libXi
      pkgs.vulkan-loader  # Si Slint utilise le renderer Skia
    ];
  };
}
