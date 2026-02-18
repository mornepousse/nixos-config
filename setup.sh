#!/usr/bin/env bash
# Script de configuration NixOS après installation Calamares
# Usage: bash setup.sh [--repo-url <url>]
# Cette script configure ta config personnelle après une install de base NixOS

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[⚠]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

# Parser arguments
REPO_URL="https://github.com/mornepousse/nixos-config"
CONFIG_DIR="$HOME/nixos-config"
MACHINE=""
HOSTNAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --machine)
      MACHINE="$2"
      shift 2
      ;;
    --hostname)
      HOSTNAME="$2"
      shift 2
      ;;
    --help)
      echo "Usage: bash setup.sh [options]"
      echo ""
      echo "Options:"
      echo "  --repo-url <url>       URL de la config"
      echo "  --machine <name>       Machine : morthinkpad ou x230t"
      echo "  --hostname <name>      Hostname de la machine (optionnel)"
      echo "  --help                 Affiche cette aide"
      echo ""
      echo "Exemples:"
      echo "  bash setup.sh --machine morthinkpad"
      echo "  bash setup.sh --machine x230t --hostname zzz"
      exit 0
      ;;
    *)
      log_error "Option inconnue: $1"
      exit 1
      ;;
  esac
done

log_info "============================"
log_info "Configuration NixOS - Setup"
log_info "============================"

# Étape 0: Vérifier et installer git
log_info ""
log_info "Étape 0: Préparation (install des outils)..."

if ! command -v git &> /dev/null; then
  log_warning "git n'est pas installé, installation en cours..."
  sudo nix-env -iA nixpkgs.git
  log_success "git installé"
else
  log_success "git trouvé"
fi

# Étape 1: Cloner la config
log_info ""
log_info "Étape 1: Clonage de la config..."

if [ -d "$CONFIG_DIR" ]; then
  log_warning "$CONFIG_DIR existe déjà"
  read -p "Veux-tu le supprimer et le re-cloner? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$CONFIG_DIR"
    git clone "$REPO_URL" "$CONFIG_DIR"
    log_success "Config clonée"
  else
    log_info "Utilisation de la config existante"
  fi
else
  git clone "$REPO_URL" "$CONFIG_DIR"
  log_success "Config clonée: $CONFIG_DIR"
fi

cd "$CONFIG_DIR"

# Étape 2: Choisir la machine
log_info ""
log_info "Étape 2: Sélection de la machine..."

if [ -z "$MACHINE" ]; then
  echo -e "${YELLOW}Machines disponibles:${NC}"
  echo "  1. morthinkpad (avec DisplayLink)"
  echo "  2. x230t (sans DisplayLink - recommandé pour ThinkPad X230t)"
  echo ""
  read -p "Quelle est ta machine? (1 ou 2, ou nom): " MACHINE_INPUT
  
  case $MACHINE_INPUT in
    1|morthinkpad)
      MACHINE="morthinkpad"
      ;;
    2|x230t)
      MACHINE="x230t"
      ;;
    *)
      log_error "Machine inconnue: $MACHINE_INPUT"
      exit 1
      ;;
  esac
fi

log_success "Machine sélectionnée: $MACHINE"

# Étape 3: Générer hardware-configuration.nix
log_info ""
log_info "Étape 3: Génération du hardware-configuration.nix..."

sudo nixos-generate-config --root /
sudo mv /etc/nixos/hardware-configuration.nix "$CONFIG_DIR/hosts/$MACHINE/hardware-configuration.nix"
log_success "hardware-configuration.nix généré et copié pour $MACHINE"

# Étape 4: Configurer le hostname (optionnel)
log_info ""
log_info "Étape 4: Configuration du hostname..."

if [ -z "$HOSTNAME" ]; then
  read -p "Quel hostname veux-tu pour cette machine? (défaut: $MACHINE) " HOSTNAME
  HOSTNAME="${HOSTNAME:-$MACHINE}"
fi

log_info "Hostname: $HOSTNAME"

# Remplacer le hostname dans la config
CONFIG_FILE="$CONFIG_DIR/hosts/$MACHINE/default.nix"
if grep -q 'networking.hostName = "' "$CONFIG_FILE"; then
  sed -i "s/networking.hostName = \"[^\"]*\"/networking.hostName = \"$HOSTNAME\"/" "$CONFIG_FILE"
  log_success "Hostname configuré: $HOSTNAME"
else
  log_warning "Impossible de trouver la ligne hostname dans la config"
fi

# Étape 5: Vérifier la structure
log_info ""
log_info "Étape 5: Vérification de la structure..."

required_files=(
  "$CONFIG_DIR/flake.nix"
  "$CONFIG_DIR/hosts/$MACHINE/default.nix"
  "$CONFIG_DIR/hosts/$MACHINE/hardware-configuration.nix"
  "$CONFIG_DIR/home/mae.nix"
)

for file in "${required_files[@]}"; do
  if [ -f "$file" ]; then
    log_success "$(basename $file)"
  else
    log_error "Manquant: $file"
    exit 1
  fi
done

# Étape 6: Build + Apply
log_info ""
log_info "Étape 6: Build et application de la config..."
log_warning "Cela peut prendre 15-30 minutes (en fonction de ton matériel)..."

sudo nixos-rebuild switch --flake "$CONFIG_DIR#$MACHINE" --show-trace

if [ $? -eq 0 ]; then
  log_success "Rebuild réussi!"
else
  log_error "Erreur lors du rebuild"
  log_info "Essaie: cd $CONFIG_DIR && sudo nixos-rebuild switch --flake .#$MACHINE --show-trace"
  exit 1
fi

# Étape 7: Home Manager
log_info ""
log_info "Étape 7: Configuration Home Manager..."

home-manager switch --flake "$CONFIG_DIR#mae"

if [ $? -eq 0 ]; then
  log_success "Home Manager appliqué!"
else
  log_warning "Home Manager a eu des problèmes, mais ce n'est pas bloquant"
fi

# Résumé final
log_info ""
log_success "============================"
log_success "Configuration terminée! ✓"
log_success "============================"
log_info ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo "  1. ${BLUE}Reboot${NC} pour appliquer les changements: ${BLUE}reboot${NC}"
echo "  2. Reconnecte-toi"
echo "  3. Commandes utiles:"
echo "     - ${BLUE}update${NC}       # Rebuild et applique"
echo "     - ${BLUE}upgrade${NC}      # Upgrade flake + rebuild"
echo "     - ${BLUE}check-updates${NC} # Voir les changements disponibles"
echo ""
echo -e "${YELLOW}Notes:${NC}"
echo "  • Machine installée: ${BLUE}$MACHINE${NC}"
echo "  • Config clonée dans: ${BLUE}$CONFIG_DIR${NC}"
echo "  • Commandes rebuild:"
echo "    - ${BLUE}sudo nixos-rebuild switch --flake $CONFIG_DIR#$MACHINE${NC}"
echo "  • Vérifier hardware: ${BLUE}cat $CONFIG_DIR/hosts/$MACHINE/hardware-configuration.nix${NC}"
echo "  • En cas de problème:"
echo "    - Reboot sur une autre génération via systemd-boot"
echo "    - Reviens et relance: ${BLUE}sudo nixos-rebuild switch --flake $CONFIG_DIR#$MACHINE${NC}"
echo ""
