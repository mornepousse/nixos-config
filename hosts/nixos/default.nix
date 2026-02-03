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

  # Kernel latest (comme ta config actuelle)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hostname
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Timezone & Locale (gardé comme ta config actuelle)
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
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

  # Clavier X11 (pour compatibilité)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

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
    nano
    neovim
    git
    wget
    curl
    htop
    unzip
    ripgrep
    fd
  ];

  # Autoriser les packages non-libres
  nixpkgs.config.allowUnfree = true;

  # Nix settings (flakes activés)
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

  # Audio avec PipeWire (comme ta config)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Polkit
  security.polkit.enable = true;

  # Version de NixOS - IMPORTANT: garde la même que ton install
  system.stateVersion = "26.05";
}
