# Installation sur Différentes Machines

Cette configuration NixOS supporte plusieurs machines avec des configurations différentes.

## Machines Disponibles

### 1. **morthinkpad** (avec DisplayLink)
- Hostname: `morthinkpad`
- Inclut le module DisplayLink pour les docks USB
- Installation: `sudo nixos-rebuild switch --flake .#morthinkpad`

### 2. **x230t** (sans DisplayLink)  
- Hostname: `x230t`
- **RECOMMANDÉ** pour ThinkPad X230t et autres machines sans dock DisplayLink
- N'installe PAS le driver DisplayLink pour éviter les crashes
- Installation: `sudo nixos-rebuild switch --flake .#x230t`

### 3. **nixos** (legacy - alias à morthinkpad)
- Gardé pour compatibilité arrière
- Pointe vers `morthinkpad`
- Installation: `sudo nixos-rebuild switch --flake .#nixos`

## Installation Rapide

### Première installation (après Calamares)
```bash
bash /root/nixos-config/setup.sh --machine x230t
```

Cela va:
1. Demander quelle machine choisir (ou utiliser `--machine`)
2. Générer le `hardware-configuration.nix` dans le bon dossier
3. Configurer le hostname
4. Appliquer la config

### Rebuild après modifications
```bash
# Pour x230t
sudo nixos-rebuild switch --flake ~/nixos-config#x230t

# Pour morthinkpad
sudo nixos-rebuild switch --flake ~/nixos-config#morthinkpad

# Ou utiliser la commande rapide 'update'
update
```

## Ajouter une Nouvelle Machine

1. Créer un nouveau dossier: `hosts/ma-nouvelle-machine/`
2. Copier `hosts/morthinkpad/default.nix` et éditer:
   - Changer `networking.hostName`
   - Ajouter/retirer les modules nécessaires (ex: displaylink.nix)
3. Générer `hardware-configuration.nix`:
   ```bash
   sudo nixos-generate-config --root /
   mv /etc/nixos/hardware-configuration.nix hosts/ma-nouvelle-machine/
   ```
4. Ajouter dans `flake.nix`:
   ```nix
   ma-nouvelle-machine = nixpkgs.lib.nixosSystem {
     system = "x86_64-linux";
     specialArgs = { inherit inputs; };
     modules = [ ./hosts/ma-nouvelle-machine ... ];
   };
   ```

## Notes Importantes

⚠️ **DisplayLink et x230t**: 
- Le module DisplayLink peut causer des crashes sur certains matériels
- La config `x230t` l'exclut donc ne charge PAS le driver DisplayLink
- Si c'est ta première install sur x230t: **utilise `--machine x230t`**

💡 **Hardware-configuration.nix**:
- Chaque machine a sa propre config hardware
- Générée automatiquement par `nixos-generate-config`
- **Ne modifie pas manuellement**, régénère-la si le matériel change

## Troubleshooting

### "Cannot find morthinkpad or x230t configuration"
→ Vérifie que `hosts/<machine>/default.nix` existe

### DisplayLink crash après install
→ Tu as peut-être installé `morthinkpad` sur x230t
→ Refais l'install avec `setup.sh --machine x230t`

### Rebuild échoue
```bash
# Voir les détails
sudo nixos-rebuild switch --flake .#<machine> --show-trace

# Revenir à une config précédente
sudo nixos-rebuild list-generations
sudo nixos-rebuild switch-generation <N>
```
