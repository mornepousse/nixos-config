{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # Support tablette ThinkPad X230 Tablet avec Libreboot
  # ============================================================================
  #
  # Périphériques gérés :
  #   - Digitizer Wacom ISD-V4 (stylet + gomme)
  #   - Écran tactile capacitif  
  #   - Switch mode tablette (SW_TABLET_MODE via MHKG)
  #   - Accéléromètre pour auto-rotation
  #
  # ============================================================================

  # --------------------------------------------------------------------------
  # Configuration kernel thinkpad_acpi
  # --------------------------------------------------------------------------

  boot.kernelModules = [
    "thinkpad_acpi"
    "industrialio"
    "lis3lv02d"
    "wacom"
  ];

  # --------------------------------------------------------------------------
  # Règles udev - Permissions périphériques tablette
  # --------------------------------------------------------------------------

  services.udev.extraRules = ''
    # === ThinkPad Extra Buttons (switch tablette + hotkeys) ===
    SUBSYSTEM=="input", ATTRS{name}=="ThinkPad Extra Buttons", MODE="0664", GROUP="input", TAG+="uaccess"

    # === Wacom digitizer interne ===
    SUBSYSTEM=="input", ATTRS{name}=="Wacom*", MODE="0664", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="input", ATTRS{name}=="Tablet ISD-V4*", MODE="0664", GROUP="input", TAG+="uaccess"

    # === Écran tactile ===
    SUBSYSTEM=="input", ATTRS{name}=="*Touchscreen*", MODE="0664", GROUP="input", TAG+="uaccess"
    SUBSYSTEM=="input", ATTRS{name}=="*touch*", MODE="0664", GROUP="input", TAG+="uaccess"

    # === Accéléromètre IIO ===
    SUBSYSTEM=="iio", MODE="0664", GROUP="input", TAG+="uaccess"
  '';

  # --------------------------------------------------------------------------
  # iio-sensor-proxy (auto-rotation via accéléromètre)
  # --------------------------------------------------------------------------

  hardware.sensor.iio.enable = true;

  # --------------------------------------------------------------------------
  # Paquets support tablette
  # --------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    # Wacom
    libwacom
    xf86_input_wacom
    kdePackages.wacomtablet

    # Clavier virtuel
    squeekboard

    # Debug et outils
    iio-sensor-proxy
    libinput
    evtest

    # Navigation tablette
    wl-kbptr

    # Prise de notes
    xournalpp
    rnote

    # Dessin
    krita
    mypaint
  ];

  # Groupe input pour accès périphériques
  users.groups.input = {};
}
