{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
   #sourcegit
   esphome
   platformio
   disktui
  ];

}
