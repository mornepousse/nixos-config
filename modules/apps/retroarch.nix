# Émulateur RetroArch avec cores Game Boy / GBA
# Auto-sauvegarde d'état activée (fermer sans perdre la progression)
{ config, pkgs, ... }:

let
  # RetroArch avec les cores Game Boy sélectionnés
  retroarch = pkgs.retroarch.withCores (cores: with cores; [
    gambatte  # Game Boy / Game Boy Color (Pokémon Rouge/Bleu/Or/Argent/Cristal)
    mgba      # Game Boy Advance (Pokémon Rubis/Saphir/Emeraude/Rouge Feu/Vert Feuille)
  ]);
in
{
  environment.systemPackages = [ retroarch ];
}
