# ATTENTION: Ce fichier doit être remplacé par celui généré sur ta machine !
# Exécute: sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# Ou copie ton /etc/nixos/hardware-configuration.nix ici

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Placeholder - À REMPLACER avec ta vraie config hardware
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ]; # ou kvm-amd selon ton CPU
  boot.extraModulePackages = [ ];

  # Filesystems - À ADAPTER selon tes partitions
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/XXXX";
  #   fsType = "ext4";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/XXXX";
  #   fsType = "vfat";
  # };

  # swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
