{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
   #sourcegit
   esphome
   platformio
   disktui
   filezilla
   github-copilot-cli
   gperf
   ccache
   python314Packages.tkinter
   file
   dtc
   smartmontools
   gparted
   nmap
  ];
  networking.firewall.allowedUDPPorts = [ 69 ];
  services.udev.packages = [ pkgs.platformio-core.udev ];
}
