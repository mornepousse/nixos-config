{ config, pkgs, ... }:

{
  # Support client NFS
  services.rpcbind.enable = true;
  
  # Montages NFS permanents
  fileSystems."/mnt/nas/fullaccess" = {
    device = "192.168.1.11:/FULLACCESS";
    fsType = "nfs";
    options = [ 
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "nfsvers=4"
    ];
  };

  fileSystems."/mnt/nas/products" = {
    device = "192.168.1.11:/PRODUCTS";
    fsType = "nfs";
    options = [ 
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "nfsvers=4"
    ];
  };

  fileSystems."/mnt/nas/bruitages" = {
    device = "192.168.1.11:/BRUITAGES";
    fsType = "nfs";
    options = [ 
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "nfsvers=4"
    ];
  };

  # Créer les points de montage
  systemd.tmpfiles.rules = [
    "d /mnt/nas 0755 root root -"
    "d /mnt/nas/fullaccess 0755 root root -"
    "d /mnt/nas/products 0755 root root -"
    "d /mnt/nas/bruitages 0755 root root -"
  ];
}
