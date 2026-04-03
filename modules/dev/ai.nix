{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # claude-code  # Temporairement désactivé — version 2.1.88 retirée de npm (404)
  ];
}