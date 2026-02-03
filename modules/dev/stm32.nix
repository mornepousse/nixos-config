{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # STM32CubeMX - Outil de config graphique
    stm32cubemx
    
    # Toolchain ARM
    gcc-arm-embedded
    
    # Outils de flash/debug
    openocd
    stlink
    
    # Debug
    gdb
  ];

  # Règles udev pour ST-Link
  services.udev.extraRules = ''
    # ST-Link V2
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3748", MODE="0666", GROUP="plugdev"
    
    # ST-Link V2-1
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE="0666", GROUP="plugdev"
    
    # ST-Link V3
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374d", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374e", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374f", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="3753", MODE="0666", GROUP="plugdev"
  '';
}
