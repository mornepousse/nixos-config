{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    
    # Modules
    ../../modules/hardware/usb-serial.nix
    ../../modules/desktop/niri.nix
    ../../modules/desktop/ly.nix
    ../../modules/dev/kicad.nix
    ../../modules/dev/stm32.nix
    ../../modules/dev/esp-idf.nix
    ../../modules/dev/freecad.nix
    ../../modules/apps/discord.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hostname
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone & Locale
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Clavier
  console.keyMap = "fr";

  # User
  users.users.mae = {
    isNormalUser = true;
    description = "mae";
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "dialout"  # Pour les ports série (ESP32, STM32)
      "plugdev"  # Pour les périphériques USB
      "uucp"     # Pour les ports série
    ];
    shell = pkgs.zsh;
  };

  # Enable zsh
  programs.zsh.enable = true;

  # Packages système de base
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    unzip
    ripgrep
    fd
  ];

  # Autoriser les packages non-libres (pour certains drivers)
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection automatique
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # OpenGL / Graphics
  hardware.graphics.enable = true;

  # Audio avec PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Polkit (nécessaire pour niri et autres)
  security.polkit.enable = true;

  # Version de NixOS
  system.stateVersion = "24.11";
}
