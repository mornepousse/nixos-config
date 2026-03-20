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
  ];
  networking.firewall.allowedUDPPorts = [ 69 ];
}
