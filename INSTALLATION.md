# Installation de la Config NixOS

Ce document explique comment installer la configuration NixOS sur une nouvelle machine.

Il existe **deux approches** selon votre situation:

1. **`setup.sh`** - Installation rapide sur NixOS déjà installé (via Calamares)
2. **`install-complete.sh`** - Installation complète depuis clé USB live

---

## ⚡ Option 1: Installation rapide (NixOS déjà installé)

**Utilisez cette option si:**
- Vous avez déjà installé NixOS avec Calamares
- Vous êtes connecté à internet
- Vous voulez juste appliquer la config personnalisée

### Étapes

```bash
# 1. Télécharger le script
curl -fsSL https://raw.githubusercontent.com/mornepousse/nixos-config/main/setup.sh -o setup.sh

# 2. Lancer l'installation
bash setup.sh --hostname morthinkpad

# Ou sans argument (demande le hostname)
bash setup.sh
```

### Paramètres

```bash
# Avec hostname spécifié
bash setup.sh --hostname x230t

# Voir l'aide complète
bash setup.sh --help
```

### Que fait le script?

- ✅ Installe `git` si absent
- ✅ Clone la config depuis GitHub
- ✅ Génère le `hardware-configuration.nix` automatiquement
- ✅ Configure le hostname
- ✅ Lance `nixos-rebuild switch`
- ✅ Applique la config Home Manager

### Durée

**15-30 minutes** selon le matériel et la connexion internet

### En cas de problème

Si le rebuild échoue:

```bash
# Vérifier le hardware-configuration.nix
cat ~/nixos-config/hosts/nixos/hardware-configuration.nix

# Relancer manuellement
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos --show-trace
```

---

## 🔧 Option 2: Installation complète (depuis clé USB)

**Utilisez cette option si:**
- Vous avez une clé USB NixOS bootable
- Vous ne voulez pas utiliser Calamares
- Vous voulez plus de contrôle (chiffrement LUKS, etc.)

### Préparation

1. **Créer une clé USB bootable NixOS**

```bash
# Sur Linux
sudo dd if=nixos-minimal-x86_64-linux.iso of=/dev/sdX bs=4M conv=fsync

# Sur macOS (voir docs NixOS)
```

2. **Booter sur la clé USB**
   - Insérer la clé USB
   - Au démarrage, appuyer sur F12 (ou selon le constructeur)
   - Sélectionner la clé USB

### Installation

1. **Une fois sur la clé live, lancer le script**

```bash
# Lister les disques disponibles
lsblk

# Installation sur /dev/sda
sudo bash install-complete.sh --device /dev/sda --hostname x230t

# Installation sur NVMe
sudo bash install-complete.sh --device /dev/nvme0n1 --hostname morthinkpad
```

### Paramètres disponibles

| Option | Exemple | Description |
|--------|---------|-------------|
| `--device` | `/dev/sda` | **OBLIGATOIRE** - Disque cible |
| `--hostname` | `x230t` | Hostname de la machine |
| `--swap` | `8` | Taille swap en GB (défaut: 4) |
| `--encrypt` | - | Activer chiffrement LUKS |
| `--repo-url` | URL | URL custom de la config |
| `--help` | - | Affiche l'aide |

### Exemples

```bash
# Installation simple
sudo bash install-complete.sh --device /dev/sda --hostname x230t

# Avec chiffrement LUKS
sudo bash install-complete.sh --device /dev/sda --hostname x230t --encrypt

# Avec plus de swap
sudo bash install-complete.sh --device /dev/nvme0n1 --hostname morthinkpad --swap 8

# Configuration personnalisée complète
sudo bash install-complete.sh \
  --device /dev/nvme0n1 \
  --hostname morthinkpad \
  --swap 16 \
  --encrypt \
  --repo-url https://github.com/votre-username/nixos-config
```

### Partitionnement créé

Le script crée automatiquement:

- **Partition EFI** (512 MB, FAT32) - `/boot`
- **Partition Swap** (configurable, défaut 4 GB)
- **Partition Root** (reste du disque, Btrfs)
  - Subvolumes: `nix`, `home`

### Durée

**20-45 minutes** selon:
- La connexion internet
- La vitesse du disque
- Le matériel utilisé

### En cas de problème

**Le script échoue pendant nixos-install:**

```bash
# Relancer depuis la clé live
sudo bash install-complete.sh --device /dev/sda --hostname x230t
```

**Le système ne boot pas:**

1. Relancer la clé USB
2. Monter le disque manually:
   ```bash
   mount /dev/disk/by-label/nixos /mnt
   nixos-install --flake /mnt/home/mae/nixos-config#nixos --root /mnt
   ```

**Erreur chiffrement LUKS:**

```bash
# Déverrouiller manuellement
sudo cryptsetup luksOpen /dev/sda3 nixos-root
sudo mount /dev/mapper/nixos-root /mnt
```

---

## ✅ Après l'installation

### 1. Première connexion

```bash
# Login avec utilisateur 'mae' (pas de mot de passe par défaut)
mae

# Créer un mot de passe
passwd
```

### 2. Vérifier la configuration

```bash
# Appliquer la config Home Manager
home-manager switch

# Vérifier les logs
journalctl -b

# Voir la version
nixos-version
```

### 3. Configuration Home Manager (si besoin)

```bash
# Modifier la config
vim ~/nixos-config/home/mae.nix

# Appliquer les changements
home-manager switch --flake ~/nixos-config#mae
```

### 4. Commandes utiles (alias disponibles)

```bash
update          # Rebuild et applique la config actuelle
upgrade         # Upgrade flake.lock + rebuild
check-updates   # Voir les mises à jour disponibles
clean           # Garbage collection

# Git
gs              # git status
ga              # git add
gc              # git commit
gp              # git push
```

---

## 🔐 Avec chiffrement LUKS

Si vous avez utilisé `--encrypt`:

```bash
# À chaque démarrage, vous serez demandé de saisir le mot de passe LUKS
Boot → Mot de passe LUKS → Login système
```

**Attention:**
- N'oubliez pas votre mot de passe LUKS
- Sauvegardez-le dans un endroit sûr
- Il ne peut pas être récupéré

---

## 📝 Personnalisation

### Changer le hostname après installation

```bash
# Modifier la config
vim ~/nixos-config/hosts/nixos/default.nix

# Chercher et modifier:
networking.hostName = "x230t";

# Appliquer
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

### Changer d'utilisateur

Par défaut, l'utilisateur est `mae`. Pour le changer:

```bash
vim ~/nixos-config/hosts/nixos/default.nix

# Modifier:
users.users.mae = { ... };
# En:
users.users.votre-username = { ... };

# Appliquer
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

### Désactiver certains modules

Certains modules peuvent ne pas convenir à votre matériel. Dans `hosts/nixos/default.nix`:

```nix
imports = [
  ./hardware-configuration.nix
  # Commenter les modules non voulus:
  # ../../modules/hardware/displaylink.nix
  # ../../modules/dev/rider.nix
];
```

Puis appliquer les changements:
```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

---

## 🔗 Ressources

- [Documentation NixOS](https://nixos.org/manual/)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [Hyprland](https://hyprland.org/)
- [Sway](https://swaywm.org/)

---

## ❓ Dépannage

### Git n'est pas disponible

Le script installe automatiquement `git` avec `nix-env`. Si ça échoue:

```bash
nix-shell -p git --run "bash install-complete.sh ..."
```

### Le disque n'est pas trouvé

Vérifier avec:
```bash
lsblk
```

Assurer-vous de spécifier le bon disque (ex: `/dev/sda`, pas `/dev/sda1`)

### Erreur lors du rebuild

Vérifier les logs:
```bash
sudo journalctl -u nixos-rebuild -n 50
```

Relancer le script ou le rebuild manuellement:
```bash
cd ~/nixos-config
sudo nixos-rebuild switch --flake .#nixos --show-trace
```

### Home Manager échoue

Ce n'est généralement pas bloquant. Appliquer manuellement:

```bash
home-manager switch --flake ~/nixos-config#mae
```

---

## 📧 Support

En cas de problème, consulter:
- `CLAUDE.md` - Architecture de la config
- Le README principal du repo
- Les logs système: `journalctl -b`
