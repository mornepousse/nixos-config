#!/usr/bin/env bash
# Script d'installation NixOS COMPLÈTE depuis clé USB live
# À exécuter depuis la clé NixOS live AVANT Calamares
# Usage: sudo bash install-complete.sh --device /dev/sda --hostname x230t

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

# Vérifier root
if [ "$EUID" -ne 0 ]; then
  log_error "Ce script doit être exécuté avec sudo"
  exit 1
fi

# Variables par défaut
DEVICE=""
HOSTNAME="nixos"
REPO_URL="https://github.com/mornepousse/nixos-config"
MOUNT_POINT="/mnt"
SWAP_SIZE="4"  # en GB
ENCRYPT=false
USERNAME="mae"

# Parser arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --device)
      DEVICE="$2"
      shift 2
      ;;
    --hostname)
      HOSTNAME="$2"
      shift 2
      ;;
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --swap)
      SWAP_SIZE="$2"
      shift 2
      ;;
    --encrypt)
      ENCRYPT=true
      shift
      ;;
    --help)
      cat << 'EOF'
Installation NixOS complète depuis clé live

Usage: sudo bash install-complete.sh --device /dev/sda [options]

Options requises:
  --device <path>       Disque cible (/dev/sda, /dev/nvme0n1, etc.)

Options optionnelles:
  --hostname <name>     Hostname (défaut: nixos)
  --repo-url <url>      URL de la config (défaut: GitHub mornepousse)
  --swap <size>         Taille swap en GB (défaut: 4)
  --encrypt             Activer le chiffrement LUKS
  --help                Affiche cette aide

Exemple:
  sudo bash install-complete.sh --device /dev/sda --hostname x230t
  sudo bash install-complete.sh --device /dev/nvme0n1 --hostname morthinkpad --swap 8

ATTENTION:
  • Assure-toi de spécifier le bon disque (/dev/sda et NON /dev/sda1)
  • Le disque sera entièrement supprimé
  • Les données existantes seront perdues
EOF
      exit 0
      ;;
    *)
      log_error "Option inconnue: $1"
      exit 1
      ;;
  esac
done

# Vérifier les arguments obligatoires
if [ -z "$DEVICE" ]; then
  log_error "Argument --device obligatoire"
  echo "Usage: sudo bash install-complete.sh --device /dev/sda --hostname x230t"
  exit 1
fi

# Vérifier que c'est bien une clé live
if ! [ -f "/etc/os-release" ]; then
  log_error "Impossible de déterminer l'OS"
  exit 1
fi

log_info "============================"
log_info "Installation NixOS COMPLÈTE"
log_info "============================"
log_info ""
log_info "Paramètres:"
log_info "  Disque: $DEVICE"
log_info "  Hostname: $HOSTNAME"
log_info "  Swap: ${SWAP_SIZE}GB"
log_info "  Chiffrement: $([ "$ENCRYPT" = true ] && echo 'OUI' || echo 'NON')"
log_warning ""
log_warning "⚠️  ATTENTION ⚠️"
log_warning "Toutes les données sur $DEVICE seront SUPPRIMÉES"
log_warning ""
read -p "Continuer? (taper 'OUI' pour confirmer) " confirm
if [ "$confirm" != "OUI" ]; then
  log_info "Annulé"
  exit 0
fi

# Étape 1: Vérifier le disque
log_info ""
log_info "Étape 1: Vérification du disque..."

if [ ! -b "$DEVICE" ]; then
  log_error "$DEVICE n'existe pas ou n'est pas un bloc device"
  exit 1
fi

log_success "Disque trouvé: $DEVICE"
lsblk "$DEVICE"

# Étape 2: Partitionnement et formatage
log_info ""
log_info "Étape 2: Partitionnement et formatage..."

# Démonter les partitions si montées
for part in "${DEVICE}"*; do
  if mountpoint -q "$part" 2>/dev/null; then
    log_warning "Démontage de $part..."
    umount "$part" || true
  fi
done

# Effacer table de partition existante
log_warning "Suppression de la table de partition..."
wipefs -af "$DEVICE" || true

# Créer table GPT
log_info "Création table GPT..."
parted -s "$DEVICE" mklabel gpt

# Partitions
EFI_SIZE="512"
SWAP_SECTORS=$(( (SWAP_SIZE * 1024 * 1024 * 1024) / 512 ))
EFI_END_SECTOR=$(( (EFI_SIZE * 1024 * 1024) / 512 ))
SWAP_END_SECTOR=$(( EFI_END_SECTOR + SWAP_SECTORS ))

log_info "Création des partitions..."
parted -s "$DEVICE" mkpart ESP fat32 1MiB ${EFI_SIZE}MiB
parted -s "$DEVICE" mkpart swap linux-swap ${EFI_SIZE}MiB $((EFI_SIZE + SWAP_SIZE * 1024))MiB
parted -s "$DEVICE" mkpart nixos btrfs $((EFI_SIZE + SWAP_SIZE * 1024))MiB 100%
parted -s "$DEVICE" set 1 boot on esp

# Obtenir les noms de partitions
if [[ "$DEVICE" =~ nvme ]]; then
  EFI_PART="${DEVICE}p1"
  SWAP_PART="${DEVICE}p2"
  ROOT_PART="${DEVICE}p3"
else
  EFI_PART="${DEVICE}1"
  SWAP_PART="${DEVICE}2"
  ROOT_PART="${DEVICE}3"
fi

log_info "Formatage EFI..."
mkfs.fat -F 32 "$EFI_PART"

log_info "Formatage Swap..."
mkswap "$SWAP_PART"
swapon "$SWAP_PART"

log_info "Formatage Root (Btrfs)..."
if [ "$ENCRYPT" = true ]; then
  log_warning "Chiffrement LUKS en cours..."
  read -sp "Mot de passe LUKS: " LUKS_PASS
  echo
  echo -n "$LUKS_PASS" | cryptsetup luksFormat --type luks2 "$ROOT_PART" -
  echo -n "$LUKS_PASS" | cryptsetup luksOpen "$ROOT_PART" nixos-root -
  ROOT_PART_OPEN="/dev/mapper/nixos-root"
  mkfs.btrfs -f "$ROOT_PART_OPEN"
  ROOT_UUID=$(cryptsetup luksDump "$ROOT_PART" | grep "UUID" | awk '{print $2}')
else
  mkfs.btrfs -f "$ROOT_PART"
  ROOT_PART_OPEN="$ROOT_PART"
fi

log_success "Disque partitionné et formaté"

# Étape 3: Montage des partitions
log_info ""
log_info "Étape 3: Montage des partitions..."

mkdir -p "$MOUNT_POINT"
mount "$ROOT_PART_OPEN" "$MOUNT_POINT"

# Subvolumes Btrfs (optionnel mais recommandé)
btrfs subvolume create "$MOUNT_POINT/nix" || log_warning "Subvolume nix existe déjà"
btrfs subvolume create "$MOUNT_POINT/home" || log_warning "Subvolume home existe déjà"

mkdir -p "$MOUNT_POINT/boot"
mount "$EFI_PART" "$MOUNT_POINT/boot"

log_success "Partitions montées"

# Étape 4: Générer hardware-configuration.nix
log_info ""
log_info "Étape 4: Génération du hardware-configuration.nix..."

nixos-generate-config --root "$MOUNT_POINT" --show-trace
log_success "hardware-configuration.nix généré"

# Étape 5: Cloner la config NixOS
log_info ""
log_info "Étape 5: Clonage de la config NixOS..."

# Installer git sur la clé live (peut ne pas être présent)
if ! command -v git &> /dev/null; then
  log_warning "Git non trouvé, installation..."
  nix-shell -p git --run "echo OK" > /dev/null
  nix-shell -p git
fi

CONFIG_DIR="/tmp/nixos-config"
git clone "$REPO_URL" "$CONFIG_DIR"
log_success "Config clonée"

# Copier la config générée
mv "$MOUNT_POINT/etc/nixos/hardware-configuration.nix" "$CONFIG_DIR/hosts/nixos/hardware-configuration.nix"

# Étape 6: Configurer le hostname
log_info ""
log_info "Étape 6: Configuration du hostname..."

CONFIG_FILE="$CONFIG_DIR/hosts/nixos/default.nix"
if grep -q 'networking.hostName = "nixos"' "$CONFIG_FILE"; then
  sed -i "s/networking.hostName = \"nixos\"/networking.hostName = \"$HOSTNAME\"/" "$CONFIG_FILE"
  log_success "Hostname configuré: $HOSTNAME"
fi

# Étape 7: Installation NixOS
log_info ""
log_info "Étape 7: Installation NixOS (nixos-install)..."
log_warning "Cela peut prendre 20-45 minutes selon la connexion et le matériel..."

nixos-install \
  --flake "$CONFIG_DIR#nixos" \
  --root "$MOUNT_POINT" \
  --show-trace

if [ $? -ne 0 ]; then
  log_error "Erreur lors de nixos-install"
  exit 1
fi

log_success "Installation réussie!"

# Étape 8: Finalisation
log_info ""
log_info "Étape 8: Finalisation..."

# Copier la config dans le système installé
mkdir -p "$MOUNT_POINT/home/$USERNAME/"
cp -r "$CONFIG_DIR" "$MOUNT_POINT/home/$USERNAME/nixos-config"
chown -R "$(id -u):" "$MOUNT_POINT/home/$USERNAME/nixos-config" || true

log_success "Configuration copiée dans le système"

# Résumé final
log_info ""
log_success "============================"
log_success "Installation terminée! ✓"
log_success "============================"
log_info ""
echo -e "${YELLOW}Prochaines étapes:${NC}"
echo ""
echo "  1. Reboot: ${BLUE}reboot${NC}"
echo "  2. Enlever la clé USB"
echo "  3. Login avec: ${BLUE}$USERNAME${NC} (pas de mdp, changez après)"
echo "  4. Vérifier la config:"
echo "     ${BLUE}home-manager switch${NC}"
echo ""
echo -e "${YELLOW}Notes:${NC}"
echo "  • Config disponible dans: /home/$USERNAME/nixos-config"
echo "  • Commandes utiles:"
echo "    - ${BLUE}update${NC}       # Rebuild et applique"
echo "    - ${BLUE}upgrade${NC}      # Upgrade flake + rebuild"
echo "    - ${BLUE}check-updates${NC} # Voir les changements"
echo ""
if [ "$ENCRYPT" = true ]; then
  echo -e "${YELLOW}Chiffrement:${NC}"
  echo "  • N'oublie pas ton mot de passe LUKS!"
  echo "  • À chaque boot, tu seras demandé de le saisir"
  echo ""
fi
echo -e "${YELLOW}Important:${NC}"
echo "  • Crée un mot de passe pour $USERNAME: ${BLUE}passwd${NC}"
echo "  • Si affichage USB bugué, reboot et enlève la clé avant de boot"
echo ""
