{ config, pkgs, ... }:

let
  # lpc21isp — outil de flash ISP série pour NXP LPC (pas dans nixpkgs)
  lpc21isp = pkgs.stdenv.mkDerivation {
    pname = "lpc21isp";
    version = "unstable-2024-12-22";

    src = pkgs.fetchFromGitHub {
      owner = "capiman";
      repo = "lpc21isp";
      rev = "master";
      hash = "sha256-BZvtJMtVyqsCPVhp/QL5cXJY8Q25T/RzYzHMutE24hk=";
    };

    # Le Makefile utilise -static, pas dispo sur NixOS
    buildPhase = ''
      make CFLAGS="-Wall" LDFLAGS=""
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp lpc21isp $out/bin/
    '';
  };

  # MCUXpresso IDE — wrapper FHS pour l'IDE installé dans /opt
  mcuxpresso = pkgs.buildFHSEnv {
    name = "mcuxpressoide";
    targetPkgs = pkgs: with pkgs; [
      # Base
      stdenv.cc.cc.lib
      glib
      gtk3
      nss
      nspr
      dbus
      atk
      pango
      cairo
      gdk-pixbuf
      xorg.libX11
      xorg.libXext
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      freetype
      fontconfig
      alsa-lib
      libusb-compat-0_1
      udev
      zlib
      libsecret
      webkitgtk_4_1
      zstd
    ];
    runScript = "/opt/mcuxpressoide-25.6.136/ide/mcuxpressoide";
  };
in
{
  environment.systemPackages = with pkgs; [
    # Toolchain ARM
    gcc-arm-embedded

    # Flash via ISP (série)
    lpc21isp

    # IDE NXP (installé manuellement dans /opt)
    mcuxpresso

    # Debug
    gdb
    openocd

    # LSP pour C/C++ (clangd)
    clang-tools

    # Build
    cmake
    gnumake
  ];

  # Règles udev pour FTDI + NXP debug probes
  services.udev.extraRules = ''
    # FTDI FT232 / FT2232
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666", GROUP="dialout"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", MODE="0666", GROUP="dialout"

    # NXP LPC-Link / MCU-Link / CMSIS-DAP
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0471", ATTRS{idProduct}=="df55", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0009", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0090", MODE="0666"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0143", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0143", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="0090", MODE="0666"
  '';
}
