{ config, pkgs, ... }:

{
  # Support Flatpak
  services.flatpak.enable = true;

  # KDE Discover : interface graphique pour gérer les apps Flatpak
  environment.systemPackages = with pkgs; [
    kdePackages.discover  # GUI pour gérer les apps Flatpak (backend Flatpak activé auto)
  ];

  # fwupd : requis par Discover pour les mises à jour firmware
  services.fwupd.enable = true;

  # XDG portals requis pour Flatpak sous Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Service systemd pour configurer Flathub et installer les apps Flatpak
  # Tourne après le démarrage du service flatpak (au boot et après nixos-rebuild)
  systemd.services.flatpak-setup = {
    description = "Setup Flatpak remotes and apps";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      ${pkgs.flatpak}/bin/flatpak install -y --noninteractive flathub io.github.shiftey.Desktop
    '';
  };
}
