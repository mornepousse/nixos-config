{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ESP-IDF et toolchain
    # Note: ESP-IDF est complexe sur NixOS, plusieurs options:
    
    # Option 1: Utiliser le package nixpkgs (peut être limité)
    # esp-idf-full
    
    # Option 2: Dépendances pour installer ESP-IDF manuellement
    python3
    python3Packages.pip
    python3Packages.virtualenv
    
    # Dépendances de build
    cmake
    ninja
    gcc
    git
    wget
    flex
    bison
    gperf
    
    # Libs nécessaires
    ncurses
    libusb1
    
    # Pour le monitoring série
    python3Packages.pyserial
  ];

  # Variables d'environnement utiles
  environment.variables = {
    # Si tu installes ESP-IDF dans ton home
    # IDF_PATH = "/home/mae/esp/esp-idf";
  };
}

# Note: Pour installer ESP-IDF proprement, tu peux:
# 1. Utiliser un shell.nix dédié pour tes projets ESP
# 2. Installer dans ton home avec:
#    mkdir -p ~/esp && cd ~/esp
#    git clone --recursive https://github.com/espressif/esp-idf.git
#    cd esp-idf && ./install.sh esp32
#    source export.sh
