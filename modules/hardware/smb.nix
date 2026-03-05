{ config, pkgs, ... }:

{
  # NFS est configuré dans modules/hardware/nfs.nix
  # GVFS pour le file manager (Thunar)
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  environment.systemPackages = with pkgs; [
    gvfs
  ];
}
