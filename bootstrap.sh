#!/usr/bin/env bash
set -e

CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"

# Lister les hosts disponibles
echo "Hosts disponibles :"
echo ""
for host in "$CONFIG_DIR"/hosts/*/; do
  name=$(basename "$host")
  echo "  - $name"
done
echo ""

# Demander le hostname cible
read -rp "Quel host installer ? " HOST

HOST_DIR="$CONFIG_DIR/hosts/$HOST"
if [ ! -d "$HOST_DIR" ]; then
  echo "Erreur : le host '$HOST' n'existe pas dans hosts/"
  exit 1
fi

# Copier le hardware-configuration.nix généré par l'installateur
if [ -f /etc/nixos/hardware-configuration.nix ]; then
  echo ""
  echo "Copie de /etc/nixos/hardware-configuration.nix -> hosts/$HOST/"
  cp /etc/nixos/hardware-configuration.nix "$HOST_DIR/hardware-configuration.nix"
  echo "OK"
else
  echo "Erreur : /etc/nixos/hardware-configuration.nix introuvable"
  exit 1
fi

# Appliquer la config
echo ""
echo "Application de la config flake#$HOST..."
echo ""
sudo nixos-rebuild switch --flake "$CONFIG_DIR#$HOST"

echo ""
echo "Installation terminée ! Reboot recommandé."
