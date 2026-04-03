# PLACEHOLDER — Remplacer par le fichier généré sur le Dell Latitude 5340
#
# Sur le Dell, après avoir partitionné et monté les disques :
#   nixos-generate-config --root /mnt
#   cat /mnt/etc/nixos/hardware-configuration.nix
#
# Copier le contenu ici avant de lancer nixos-install.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # ── À remplacer par les valeurs générées ────────────────────
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ── Partitions — REMPLACER les UUID par ceux du Dell ────────
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/REMPLACER-MOI";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/REMPLACER-MOI";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
