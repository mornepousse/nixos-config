{ config, pkgs, ... }:

{
  # Support Flatpak
  services.flatpak.enable = true;

  # KDE Discover : interface graphique pour gérer les apps Flatpak
  environment.systemPackages = with pkgs; [
    kdePackages.discover  # GUI pour gérer les apps Flatpak (backend Flatpak activé auto)
  ];

  # XDG portals requis pour Flatpak sous Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Apps Flatpak installées via activation
  # Nécessite que Flathub soit ajouté manuellement au premier boot :
  #   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  system.activationScripts.flatpakApps = {
    supportsDryActivation = false;
    text = ''
      if command -v flatpak &>/dev/null && flatpak remotes | grep -q flathub; then
        flatpak install -y --noninteractive flathub io.github.shiftey.Desktop 2>/dev/null || true
      fi
    '';
  };
}
