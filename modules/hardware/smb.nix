{ config, pkgs, ... }:

{
  # ── SMB/CIFS ────────────────────────────────────────────────

  # GVFS pour montage dans Thunar (smb://)
  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  environment.systemPackages = with pkgs; [
    gvfs
    cifs-utils   # mount.cifs
    libsecret    # Stockage mots de passe dans gnome-keyring
  ];
}
