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
    libX11
    libXcursor
    libXrandr
    libXi
    libXext
    libXrender
    libxcb

    mesa
    libGL
    libglvnd
    udev

    # Headers OpenGL supplémentaires
    libX11.dev
    libxcb.dev
    libxkbcommon.dev
    wayland.dev

    # Communication série (microcontrôleurs)
    # serialport-rs utilise libudev
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
      pkgs.libglvnd.dev
      pkgs.udev.dev
      pkgs.libX11.dev
      pkgs.libXcursor.dev
      pkgs.libXrandr.dev
      pkgs.libXi.dev
      pkgs.libxcb.dev
      pkgs.vulkan-loader.dev
    ];

    # Linker doit trouver les .so et headers OpenGL
    LD_LIBRARY_PATH = map (pkg: "${pkg}/lib") [
      pkgs.fontconfig.lib   # .lib output contient libfontconfig.so.1 (pas .bin)
      pkgs.freetype
      pkgs.libxkbcommon
      pkgs.libGL
      pkgs.libglvnd
      pkgs.wayland
      pkgs.libX11
      pkgs.libXcursor
      pkgs.libXrandr
      pkgs.libXi
      pkgs.libxcb
      pkgs.udev
      pkgs.vulkan-loader
    ];

    # Headers C/C++ pour compilation OpenGL
    C_INCLUDE_PATH = pkgs.lib.makeSearchPath "include" [
      pkgs.libGL.dev
      pkgs.libglvnd.dev
      pkgs.libX11.dev
      pkgs.libxcb.dev
      pkgs.libxkbcommon.dev
    ];

    CPLUS_INCLUDE_PATH = pkgs.lib.makeSearchPath "include" [
      pkgs.libGL.dev
      pkgs.libglvnd.dev
      pkgs.libX11.dev
      pkgs.libxcb.dev
      pkgs.libxkbcommon.dev
    ];
  };
}
