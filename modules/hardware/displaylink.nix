{ config, pkgs, ... }:

{
  # Driver DisplayLink pour hubs/docks Dell (et autres)
  services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  # Module kernel evdi nécessaire pour DisplayLink
  boot.extraModulePackages = with config.boot.kernelPackages; [
    evdi
  ];

  # Paquet DisplayLink + script de reload
  environment.systemPackages = with pkgs; [
    displaylink
    (pkgs.writeShellScriptBin "displaylink-reload" ''
      echo "Reloading DisplayLink..."
      sudo ${pkgs.systemd}/bin/systemctl restart dlm.service
      sudo ${pkgs.kmod}/bin/modprobe -r evdi
      sudo ${pkgs.kmod}/bin/modprobe evdi
      echo "DisplayLink reloaded. Wait 10-30s for screens to connect."
    '')
  ];

  # Service DisplayLink - Démarrage automatique au boot
  # NOTE: Prend 10-30s pour initialiser les écrans
  systemd.services.dlm = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
  };
}
