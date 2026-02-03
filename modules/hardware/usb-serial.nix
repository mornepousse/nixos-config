{ config, pkgs, ... }:

{
  # Support pour les convertisseurs USB-Serial (ESP32, STM32, Arduino...)
  
  # Modules kernel pour CH340 et CP210x
  boot.kernelModules = [
    "ch341"      # CH340/CH341 (très courant sur les ESP32 chinois)
    "cp210x"     # CP2102/CP2104 (Silicon Labs)
    "ftdi_sio"   # FTDI (FT232, etc.)
    "pl2303"     # Prolific
  ];

  # Règles udev pour accès sans root
  services.udev.extraRules = ''
    # CH340/CH341
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", MODE="0666", GROUP="plugdev", SYMLINK+="ttyUSB_CH340_%n"
    
    # CH340C
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", MODE="0666", GROUP="plugdev"
    
    # CP2102
    SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0666", GROUP="plugdev", SYMLINK+="ttyUSB_CP210x_%n"
    
    # CP2104
    SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea61", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea61", MODE="0666", GROUP="plugdev"
    
    # FTDI FT232
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", MODE="0666", GROUP="plugdev"
    
    # ESP32-S2/S3 USB natif (mode CDC)
    SUBSYSTEM=="usb", ATTRS{idVendor}=="303a", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="303a", MODE="0666", GROUP="plugdev"
  '';

  # Créer le groupe plugdev
  users.groups.plugdev = {};

  # Outils pour debug série
  environment.systemPackages = with pkgs; [
    minicom
    picocom
    screen
    usbutils  # lsusb
  ];
}
