{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    signal-cli
    brave
  ];
}
