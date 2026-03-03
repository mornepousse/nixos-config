#!/usr/bin/env bash
# Script d'installation NixOS COMPLÈTE depuis clé USB live
# À exécuter depuis la clé NixOS live AVANT Calamares
# Usage: sudo bash install-complete.sh --device /dev/sda --machine x230t

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
MACHINE=""
HOSTNAME=""
REPO_URL="https://github.com/mornepousse/nixos-config"
MOUNT_POINT="/mnt"
SWAP_SIZE="4"  # en GB
ENCRYPT=false
USERNAME="mae"

# Parser arguments
USER_PASSWORD=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --device)
      DEVICE="$2"
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
    --password)
      USER_PASSWORD="$2"
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

Usage: sudo bash install-complete.sh --device /dev/sda --machine <nom> [options]

Options requises:
  --device <path>       Disque cible (/dev/sda, /dev/nvme0n1, etc.)
  --machine <name>      Machine : morthinkpad ou x230t

Options optionnelles:
  --hostname <name>     Hostname (ex: x230t, morthinkpad, etc.)
  --password <pwd>      Mot de passe pour mae (sinon: demandé à l'installation)
  --repo-url <url>      URL de la config (défaut: GitHub mornepousse)
  --swap <size>         Taille swap en GB (défaut: 4)
  --encrypt             Activer le chiffrement LUKS (même mot de passe que l'utilisateur)
  --help                Affiche cette aide

Exemple:
  sudo bash install-complete.sh --device /dev/sda --machine x230t
  sudo bash install-complete.sh --device /dev/nvme0n1 --machine morthinkpad --hostname morthinkpad --swap 8

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
  echo "Usage: sudo bash install-complete.sh --device /dev/sda --machine x230t"
  exit 1
fi

if [ -z "$MACHINE" ]; then
  log_error "Argument --machine obligatoire (morthinkpad ou x230t)"
  echo "Usage: sudo bash install-complete.sh --device /dev/sda --machine x230t"
  exit 1
fi

# Valider la machine
if [[ ! "$MACHINE" =~ ^(morthinkpad|x230t)$ ]]; then
  log_error "Machine inconnue: $MACHINE (doit être morthinkpad ou x230t)"
  exit 1
fi

# Demander le mot de passe si non fourni
if [ -z "$USER_PASSWORD" ]; then
  log_info ""
  log_warning "Veuillez entrer un mot de passe pour l'utilisateur $USERNAME"
  while true; do
    read -sp "Mot de passe: " pass1
    echo
    read -sp "Confirmez le mot de passe: " pass2
    echo
    if [ "$pass1" = "$pass2" ]; then
      USER_PASSWORD="$pass1"
      break
    else
      log_error "Les mots de passe ne correspondent pas, réessayez."
    fi
  done
  # Sécuriser: ne pas l'afficher
  unset pass1 pass2
fi

# Générer le hash du mot de passe (SHA-512 requis pour NixOS hashedPassword)
log_info "Génération du hash du mot de passe..."
if command -v mkpasswd &> /dev/null; then
  PASS_HASH=$(echo -n "$USER_PASSWORD" | mkpasswd -m sha-512 -s 2>/dev/null)
elif command -v openssl &> /dev/null; then
  PASS_HASH=$(echo -n "$USER_PASSWORD" | openssl passwd -6 -stdin 2>/dev/null)
else
  log_error "Aucun outil disponible pour hasher le mot de passe (besoin mkpasswd ou openssl)"
  exit 1
fi

if [ -z "$PASS_HASH" ]; then
  log_error "Impossible de générer le hash du mot de passe"
  exit 1
fi
log_success "Hash généré"

# Définir le hostname par défaut en fonction de la machine si non spécifié
if [ -z "$HOSTNAME" ]; then
  HOSTNAME="$MACHINE"
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
log_info "  Machine: $MACHINE"
log_info "  Disque: $DEVICE"
log_info "  Hostname: $HOSTNAME"
log_info "  Boot: $([ "$MACHINE" = "x230t" ] && echo 'GRUB BIOS (Libreboot)' || echo 'systemd-boot (UEFI)')"
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

# Étape 2: Nettoyage + Partitionnement et formatage
log_info ""
log_info "Étape 2: Nettoyage et partitionnement..."

# --- Nettoyage complet (gère un re-run après échec) ---
log_info "Nettoyage des montages/swap/LUKS existants..."

# Démonter les sous-montages de /mnt en premier (ordre inverse)
for mnt in "$MOUNT_POINT/boot" "$MOUNT_POINT/nix" "$MOUNT_POINT/home" "$MOUNT_POINT"; do
  if mountpoint -q "$mnt" 2>/dev/null; then
    log_warning "Démontage de $mnt..."
    umount -l "$mnt" || true
  fi
done

# Désactiver le swap sur les partitions du device
for part in "${DEVICE}"*; do
  if [ -b "$part" ] && grep -q "$part" /proc/swaps 2>/dev/null; then
    log_warning "Désactivation du swap sur $part..."
    swapoff "$part" || true
  fi
done

# Fermer LUKS si ouvert (re-run avec --encrypt)
if [ -b /dev/mapper/nixos-root ]; then
  log_warning "Fermeture du volume LUKS nixos-root..."
  umount -l /dev/mapper/nixos-root 2>/dev/null || true
  cryptsetup luksClose nixos-root || true
fi

# Démonter toute partition du device encore montée (filet de sécurité)
for part in "${DEVICE}"*; do
  if [ -b "$part" ] && findmnt -rn "$part" > /dev/null 2>&1; then
    log_warning "Démontage de $part..."
    umount -l "$part" || true
  fi
done

# Effacer table de partition existante
log_warning "Suppression de la table de partition..."
wipefs -af "$DEVICE" || true
partprobe "$DEVICE" 2>/dev/null || true
sleep 1  # Laisser le kernel relire la table de partitions

# Créer table GPT
log_info "Création table GPT..."
parted -s "$DEVICE" mklabel gpt

# Partitions : schéma différent selon UEFI ou BIOS (Libreboot)
log_info "Création des partitions..."

if [ "$MACHINE" = "x230t" ]; then
  # x230t avec Libreboot : BIOS boot partition (ef02) + swap + root
  BOOT_SIZE="2"  # 2 MiB pour BIOS boot
  parted -s "$DEVICE" mkpart bios_boot 1MiB ${BOOT_SIZE}MiB
  parted -s "$DEVICE" set 1 bios_grub on
  parted -s "$DEVICE" mkpart swap linux-swap ${BOOT_SIZE}MiB $((BOOT_SIZE + SWAP_SIZE * 1024))MiB
  parted -s "$DEVICE" mkpart nixos btrfs $((BOOT_SIZE + SWAP_SIZE * 1024))MiB 100%
else
  # morthinkpad et autres : ESP (UEFI) + swap + root
  EFI_SIZE="512"
  parted -s "$DEVICE" mkpart ESP fat32 1MiB ${EFI_SIZE}MiB
  parted -s "$DEVICE" mkpart swap linux-swap ${EFI_SIZE}MiB $((EFI_SIZE + SWAP_SIZE * 1024))MiB
  parted -s "$DEVICE" mkpart nixos btrfs $((EFI_SIZE + SWAP_SIZE * 1024))MiB 100%
  parted -s "$DEVICE" set 1 boot on
fi

# Obtenir les noms de partitions
if [[ "$DEVICE" =~ nvme ]]; then
  BOOT_PART="${DEVICE}p1"
  SWAP_PART="${DEVICE}p2"
  ROOT_PART="${DEVICE}p3"
else
  BOOT_PART="${DEVICE}1"
  SWAP_PART="${DEVICE}2"
  ROOT_PART="${DEVICE}3"
fi

# Formatage partition 1 : seulement pour UEFI (BIOS boot n'a pas de filesystem)
if [ "$MACHINE" != "x230t" ]; then
  log_info "Formatage EFI..."
  mkfs.fat -F 32 "$BOOT_PART"
fi

log_info "Formatage Swap..."
mkswap "$SWAP_PART"
swapon "$SWAP_PART"

log_info "Formatage Root (Btrfs)..."
if [ "$ENCRYPT" = true ]; then
  log_warning "Chiffrement LUKS2 en cours (même mot de passe que l'utilisateur)..."
  echo -n "$USER_PASSWORD" | cryptsetup luksFormat --type luks2 "$ROOT_PART" --key-file=-
  echo -n "$USER_PASSWORD" | cryptsetup luksOpen "$ROOT_PART" nixos-root --key-file=-
  ROOT_PART_OPEN="/dev/mapper/nixos-root"
  mkfs.btrfs -f "$ROOT_PART_OPEN"
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

# Monter /boot seulement en UEFI (la partition BIOS boot ne se monte pas)
if [ "$MACHINE" != "x230t" ]; then
  mkdir -p "$MOUNT_POINT/boot"
  mount "$BOOT_PART" "$MOUNT_POINT/boot"
fi

log_success "Partitions montées"

# Étape 4: Générer hardware-configuration.nix
log_info ""
log_info "Étape 4: Génération du hardware-configuration.nix..."

nixos-generate-config --root "$MOUNT_POINT"
log_success "hardware-configuration.nix généré"

# Étape 5: Cloner la config NixOS
log_info ""
log_info "Étape 5: Clonage de la config NixOS..."

# Nettoyer un éventuel clone précédent (re-run du script)
CONFIG_DIR="/tmp/nixos-config"
if [ -d "$CONFIG_DIR" ]; then
  log_warning "Suppression de l'ancien clone $CONFIG_DIR..."
  rm -rf "$CONFIG_DIR"
fi

# Cloner la config (nix-shell -p git si git absent sur la clé live)
if command -v git &> /dev/null; then
  git clone "$REPO_URL" "$CONFIG_DIR"
else
  log_warning "Git non trouvé, utilisation de nix-shell..."
  nix-shell -p git --run "git clone '$REPO_URL' '$CONFIG_DIR'"
fi
log_success "Config clonée"

# Copier la config générée
mv "$MOUNT_POINT/etc/nixos/hardware-configuration.nix" "$CONFIG_DIR/hosts/$MACHINE/hardware-configuration.nix"
log_success "hardware-configuration.nix copié vers hosts/$MACHINE/"

# Étape 6: Configurer le hostname et le mot de passe
log_info ""
log_info "Étape 6: Configuration du hostname et du mot de passe..."

CONFIG_FILE="$CONFIG_DIR/hosts/$MACHINE/default.nix"
if grep -q 'networking.hostName = "' "$CONFIG_FILE"; then
  # Remplacer le hostname existant (utiliser | comme délimiteur pour éviter //// dans les chemins)
  sed -i "s|networking.hostName = \"[^\"]*\"|networking.hostName = \"$HOSTNAME\"|" "$CONFIG_FILE"
  log_success "Hostname configuré: $HOSTNAME"
else
  log_warning "Impossible de trouver la ligne hostname"
fi

# Configurer le mot de passe dans la config
# Créer un fichier temporaire avec les modifications
TEMP_CONFIG=$(mktemp)
awk -v hash="$PASS_HASH" '
  /users.users.mae = \{/ { in_user=1 }
  in_user && /shell = pkgs.zsh;/ {
    print $0
    print "    hashedPassword = \"" hash "\";"
    next
  }
  { print }
  /^  \};$/ && in_user { in_user=0 }
' "$CONFIG_FILE" > "$TEMP_CONFIG"

if grep -q 'hashedPassword' "$TEMP_CONFIG"; then
  mv "$TEMP_CONFIG" "$CONFIG_FILE"
  log_success "Mot de passe configuré pour $USERNAME"
else
  log_warning "Impossible de configurer le mot de passe"
  rm -f "$TEMP_CONFIG"
fi

# Étape 7: Installation NixOS
log_info ""
log_info "Étape 7: Installation NixOS (nixos-install)..."
log_warning "Cela peut prendre 20-45 minutes selon la connexion et le matériel..."
log_info "Machine: $MACHINE"

if nixos-install \
  --flake "$CONFIG_DIR#$MACHINE" \
  --root "$MOUNT_POINT" \
  --no-root-passwd \
  --show-trace; then
  log_success "Installation réussie!"
else
  log_error "Erreur lors de nixos-install"
  exit 1
fi

# Étape 8: Finalisation
log_info ""
log_info "Étape 8: Finalisation..."

# Copier la config dans le système installé
mkdir -p "$MOUNT_POINT/home/$USERNAME/"
cp -r "$CONFIG_DIR" "$MOUNT_POINT/home/$USERNAME/nixos-config"
# UID 1000 = premier utilisateur normal créé par NixOS (mae)
chown -R 1000:100 "$MOUNT_POINT/home/$USERNAME/nixos-config" || true

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
echo "  3. Login avec: ${BLUE}$USERNAME${NC} / mot de passe que tu viens de défini"
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
  echo -e "${YELLOW}Chiffrement LUKS:${NC}"
  echo "  • Le mot de passe LUKS = mot de passe de $USERNAME"
  echo "  • À chaque boot, tu devras le saisir pour déverrouiller le disque"
  echo "  • Tu peux ajouter un autre mot de passe LUKS plus tard avec:"
  echo "    ${BLUE}sudo cryptsetup luksAddKey /dev/sda3${NC}"
  echo ""
fi
echo -e "${YELLOW}Important:${NC}"
echo "  • Le mot de passe a été configuré automatiquement ✓"
echo "  • Tu peux le changer plus tard avec: ${BLUE}passwd${NC}"
echo "  • Si affichage USB bugué, reboot et enlève la clé avant de boot"
echo ""
