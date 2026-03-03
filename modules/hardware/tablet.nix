{ config, pkgs, ... }:

{
  # Support tablette pour X230 Tablet (Libreboot)
  # Digitizer Wacom, ecran tactile, accelerometre, clavier virtuel

  # Modules kernel pour les capteurs IIO (accelerometre)
  boot.kernelModules = [
    "industrialio"     # Framework IIO pour les capteurs
    "lis3lv02d"        # Accelerometre Lenovo ThinkPad (ACPI)
    "lis3lv02d_i2c"    # Variante I2C de l'accelerometre
    "wacom"            # Driver Wacom kernel
  ];

  # Service iio-sensor-proxy pour l'auto-rotation via accelerometre
  hardware.sensor.iio.enable = true;

  # Support Wacom sous Wayland :
  # Le module kernel "wacom" (hid-wacom) gere le hardware.
  # libwacom + libinput gerent le userspace (pas besoin de xf86-input-wacom).
  # On n'active PAS services.xserver.wacom.enable car on est sous Hyprland (Wayland).

  # Regles udev pour les peripheriques tablette
  services.udev.extraRules = ''
    # Wacom digitizer interne (X230 Tablet)
    SUBSYSTEM=="input", ATTRS{name}=="Wacom ISDv4 *", MODE="0666", GROUP="plugdev"

    # Ecran tactile
    SUBSYSTEM=="input", ATTRS{name}=="*Touchscreen*", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="input", ATTRS{name}=="*touch*", MODE="0666", GROUP="plugdev"

    # Boutons tablette ThinkPad
    SUBSYSTEM=="input", ATTRS{name}=="ThinkPad Extra Buttons", MODE="0666", GROUP="plugdev"

    # Accelerometre IIO
    SUBSYSTEM=="iio", MODE="0666", GROUP="plugdev"
  '';

  # Paquets pour le support tablette
  environment.systemPackages = with pkgs; [
    # Wacom
    libwacom           # Bibliotheque Wacom (detection tablettes)
    xf86_input_wacom   # Driver Wacom X11 (utile si apps XWayland utilisent le stylet)
    kdePackages.wacomtablet  # KDE Wacom settings GUI (config pression, mapping zones)

    # Clavier virtuel pour mode tablette
    squeekboard        # Clavier virtuel adapte aux ecrans tactiles (GTK/Wayland)

    # Outils capteurs et debug
    iio-sensor-proxy   # Proxy D-Bus pour capteurs IIO (accelerometre)
    libinput           # Bibliotheque de gestion des peripheriques d'entree

    # Utilitaires tablette Wayland
    wl-kbptr           # Navigation clavier/stylet pour Wayland (deplacer le curseur sans souris)

    # Prise de notes manuscrites avec stylet
    xournalpp          # Notes manuscrites, annotation PDF, excellent support Wacom
    rnote              # Notes vectorielles modernes (Rust/GTK4, pense pour stylet)

    # Dessin avec support pression du stylet
    krita              # Dessin/peinture numerique professionnel, support tablette/pression
    mypaint            # Dessin libre avec brosses naturelles, leger, bon support Wacom
  ];

  # Groupe plugdev pour acces peripheriques
  users.groups.plugdev = {};
}
