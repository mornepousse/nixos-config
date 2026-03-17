{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Toolchain ARM
    gcc-arm-embedded

    # Build system
    cmake
    gnumake

    # Python + intelhex (conversion HEX → UF2)
    python3
    python3Packages.intelhex

    # nRF Command Line Tools (optionnel, pour J-Link)
    # nrf-command-line-tools  # pas dans nixpkgs, utiliser J-Link directement si besoin
  ];

  # Règles udev pour nice!nano en mode bootloader (USB mass storage)
  # et pour J-Link (debug/RTT)
  services.udev.extraRules = ''
    # nice!nano v2 bootloader (Adafruit UF2)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="239a", MODE="0666", GROUP="plugdev"

    # SEGGER J-Link
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1366", MODE="0666", GROUP="plugdev"
  '';
}
