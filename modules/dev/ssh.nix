{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sshpass         # Fournir le mot de passe à SSH en non-interactif
    openssh
    ubootTools
  ];
}
