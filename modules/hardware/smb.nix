{ config, pkgs, ... }:

{
  # NFS est configuré dans modules/hardware/nfs.nix
  # Ce fichier garde juste GVFS pour Nemo
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  environment.systemPackages = with pkgs; [
    gvfs
  ];
}
