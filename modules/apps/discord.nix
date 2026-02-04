{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Vesktop - Client Discord avec Vencord intégré
    # Meilleur support Wayland/Niri que le client officiel
    vesktop
    
    # Discord officiel (peut avoir des problèmes sur Wayland)
    # discord
  ];
}
