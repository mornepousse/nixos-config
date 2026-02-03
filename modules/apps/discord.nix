{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Discord officiel (nécessite allowUnfree = true)
    discord
    
    # Alternative open source (si tu préfères)
    # vesktop  # Client Discord avec Vencord intégré
  ];
}
