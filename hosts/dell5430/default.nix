{ config, pkgs, inputs, ... }:

{
  # ══════════════════════════════════════════════════════════════
  #  dell5430 — Dell Latitude 5430 (remplace morthinkpad)
  # ══════════════════════════════════════════════════════════════

  imports = [
    ./hardware-configuration.nix

    # ── Hardware ────────────────────────────────────────────────
    # Pas de DisplayLink sur le Dell Latitude 5430
    ../../modules/hardware/usb-serial.nix    # CH340, CP210x
    ../../modules/hardware/dns.nix
    ../../modules/hardware/smb.nix           # Partages réseau SMB/CIFS
    ../../modules/hardware/nfs.nix           # Partages réseau NFS

    # ── Desktop / Wayland ──────────────────────────────────────
    ../../modules/desktop/hyprland.nix       # Compositor principal
    ../../modules/desktop/console.nix        # TTY
    # ../../modules/desktop/desktop-others.nix # réactiver après install
    ../../modules/desktop/quickshell.nix     # Waybar

    # ── Dev (désactivés pour l'install, réactiver après) ───────
    ../../modules/dev/ssh.nix
    # ../../modules/dev/ai.nix              # claude-code — réactiver après install
    # ../../modules/dev/dev_other.nix       # réactiver après install
    # ../../modules/dev/kicad.nix           # réactiver après install
    # ../../modules/dev/stm32.nix           # réactiver après install
    # ../../modules/dev/nrf52.nix           # réactiver après install
    # ../../modules/dev/esp-idf.nix         # réactiver après install
    # ../../modules/dev/freecad.nix         # réactiver après install
    # ../../modules/dev/slint-rust.nix      # réactiver après install
    # ../../modules/dev/qt-quick.nix        # réactiver après install
    # ../../modules/dev/rider.nix           # réactiver après install

    # ── Apps (désactivées pour l'install, réactiver après) ─────
    ../../modules/apps/thunar.nix            # Gestionnaire de fichiers
    # ../../modules/apps/discord.nix        # réactiver après install
    # ../../modules/apps/disk-tools.nix     # réactiver après install
    ../../modules/apps/flatpak.nix
    # ../../modules/apps/affinity.nix       # réactiver après install
    # ../../modules/apps/retroarch.nix      # réactiver après install
  ];

  # ── Boot ────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # ── Kernel ──────────────────────────────────────────────────
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # ── Réseau ──────────────────────────────────────────────────
  networking.hostName = "dell5430";
  networking.networkmanager.enable = true;

  # ── Locale ──────────────────────────────────────────────────
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

  # ── Clavier (X11 compat) ────────────────────────────────────
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  # ── Utilisateur ─────────────────────────────────────────────
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

  # ── Shells ──────────────────────────────────────────────────
  programs.zsh.enable = true;
  programs.fish.enable = true;

  # ── Packages système de base ────────────────────────────────
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

  # ── Nix settings ────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  # ── Nix flakes & GC ────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    keep-derivations = true;
    keep-outputs = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # ── Hardware (GPU, Bluetooth) ───────────────────────────────
  hardware.graphics.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
      };
    };
  };
  services.blueman.enable = true;

  # ── Audio (PipeWire) ────────────────────────────────────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ── Sécurité & Polkit ───────────────────────────────────────
  security.polkit.enable = true;

  # dconf/GSettings - nécessaire pour les dialogues de fichiers GTK
  programs.dconf.enable = true;

  # ── Mode docked (capot fermé) ──────────────────────────────
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # ── Énergie ─────────────────────────────────────────────────
  services.power-profiles-daemon.enable = true;

  # ── Keyring ─────────────────────────────────────────────────
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # ══════════════════════════════════════════════════════════════
  # NE JAMAIS modifier sans migration
  system.stateVersion = "26.05";
}
