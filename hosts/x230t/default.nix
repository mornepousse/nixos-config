{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # Modules
    ../../modules/hardware/usb-serial.nix
    ../../modules/hardware/dns.nix
    ../../modules/hardware/smb.nix
    ../../modules/hardware/nfs.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/console.nix
    ../../modules/desktop/desktop-others.nix
    ../../modules/desktop/quickshell.nix
    ../../modules/dev/kicad.nix
    ../../modules/dev/stm32.nix
    ../../modules/dev/esp-idf.nix
    ../../modules/dev/freecad.nix
    ../../modules/dev/slint-rust.nix
    ../../modules/dev/qt-quick.nix
    ../../modules/dev/rider.nix
    # ../../modules/dev/qtcreator.nix    # Remplacé par Slint + Rust
    ../../modules/dev/ssh.nix
    ../../modules/apps/nemo.nix
    ../../modules/apps/discord.nix
    ../../modules/apps/disk-tools.nix
    ../../modules/apps/flatpak.nix
    ../../modules/dev/ai.nix
    ../../modules/dev/dev_other.nix
    # ../../modules/hardware/displaylink.nix  # ✗ Sans DisplayLink (x230t)
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;  # Limite à 10 versions dans le menu boot

  # Kernel latest (comme ta config actuelle)
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Hostname
  networking.hostName = "x230t";
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

  # Enable shells
  programs.zsh.enable = true;
  programs.fish.enable = true;

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
    bluetui
    vscode.fhs  # VSCode avec FHS pour compatibilité extensions
    nvd          # Diff entre générations NixOS
    nh           # Helper NixOS (wrapper nixos-rebuild + nvd intégré)
  ];

  # Autoriser les packages non-libres
  nixpkgs.config.allowUnfree = true;

  # Nix settings (flakes activés)
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # Garder les sources téléchargées (ex: DisplayLink) pour éviter re-téléchargement
    keep-derivations = true;
    keep-outputs = true;
  };

  # Garbage collection automatique
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";  # 30 jours pour garder les sources plus longtemps
  };

  # OpenGL / Graphics
  hardware.graphics.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;  # Active le Bluetooth au démarrage
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;  # Pour certaines fonctionnalités avancées
      };
    };
  };
  services.blueman.enable = true;  # GUI pour gérer le Bluetooth

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

  # Mode docked : permettre de garder le laptop fermé sur secteur
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";                    # Par défaut : suspend quand capot fermé
    HandleLidSwitchExternalPower = "ignore";        # Sur secteur : ignorer le capot fermé
    HandleLidSwitchDocked = "ignore";               # Avec écran externe : ignorer le capot fermé
  };

  # Profils d'énergie (performance / balanced / power-saver)
  services.power-profiles-daemon.enable = true;

  # Keyring (pour SMB, GitHub Desktop, tokens, etc.)
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Version de NixOS - IMPORTANT: garde la même que ton install
  system.stateVersion = "26.05";
}
