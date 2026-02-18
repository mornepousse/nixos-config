# Qt Creator + Qt6 Deployment Guide

## Changements effectués (commit ea75617)

Ce commit ajoute Qt Creator IDE avec support complet de Qt6 sur NixOS, avec auto-détection des kits et chemins.

### 1. Module NixOS amélioré : `modules/dev/qt-quick.nix`

**Avant** :
- Qt6 minimal (qtbase, qtdeclarative, qttools)
- Variables d'environnement basiques

**Après** :
- Qt6 complet + Qt Creator IDE
- Packages supplémentaires : qt6.full, qt6.qtconnectivity, qt6.qtmultimedia
- Outils : qtcreator, lldb (en plus de clang-tools)
- Variables d'environnement pour auto-détection Qt Creator :
  - `CMAKE_PREFIX_PATH` : Tous les modules Qt6
  - `Qt6_DIR` : Chemin critique pour CMake
  - `QT_QPA_PLATFORM_PLUGIN_PATH` : Pour affichage GUI
  - Autres : QT_PLUGIN_PATH, QML2_IMPORT_PATH, CMAKE_INCLUDE_PATH, CMAKE_LIBRARY_PATH

### 2. Script `new-qt-project` amélioré : `home/mae.nix`

**Nouvelles fonctionnalités** :
- Génère fichier `.pro` pour Qt Creator recognition
- Crée script `build.sh` pour compilation simple
- Fichier `.clangd` optimisé pour Qt6 LSP

**Fichiers générés par le script** :
```
mon-app/
├── CMakeLists.txt         # find_package(Qt6) automatique
├── src/
│   └── main.cpp
├── ui/
│   └── Main.qml
├── .clangd                # Config clangd pour Neovim LSP
├── mon-app.pro            # Fichier .pro pour Qt Creator
├── build/                 # Dossier build (créé vide)
└── build.sh               # Script helper (cmake + ninja)
```

### 3. Documentation et outils

- **SETUP-QT-CREATOR.md** (896 lignes) : Guide complet
  - Installation et vérification
  - Création de projets
  - Intégration CMake + Qt Creator
  - Intégration clangd + Neovim
  - Troubleshooting détaillé

- **test-qt-setup.sh** : Script de vérification
  - Vérifie les binaires installés
  - Vérifie les variables d'environnement
  - Test optionnel de compilation CMake

## Déploiement (étapes à suivre)

### Étape 1 : Appliquer la configuration NixOS

```bash
# Dans le répertoire de configuration
cd ~/nixos-config

# Appliquer le nouveau module qt-quick.nix et script new-qt-project
sudo nixos-rebuild switch --flake .#nixos
```

**Temps estimé** : 10-20 minutes (dépend du cache Nix)

**Checkpoints** :
- Le rebuild doit se terminer sans erreurs
- Qt Creator est maintenant disponible dans le PATH

### Étape 2 : Vérifier l'installation

```bash
# Option 1 : Test automatisé
./test-qt-setup.sh

# Option 2 : Tests manuels
which qtcreator                    # Vérifier Qt Creator
echo $CMAKE_PREFIX_PATH            # Vérifier chemins Qt6
echo $Qt6_DIR                       # Vérifier Qt6_DIR

# Vérifier qu'on peut créer un projet
new-qt-project test-app
```

**Résultat attendu** :
- `qtcreator` trouvé dans `/run/current-system/sw/bin/`
- `CMAKE_PREFIX_PATH` contient `/nix/store/*-qtbase-*` et autres modules Qt6
- `Qt6_DIR` défini vers `/nix/store/*-qtbase-*/lib/cmake/Qt6`

### Étape 3 : Test de création et compilation

```bash
# Créer un nouveau projet
new-qt-project my-test-app
cd my-test-app

# Compiler avec le script helper
./build.sh

# Lancer l'application
./build/app
```

**Résultat attendu** :
- CMake configure correctement avec Qt6 trouvé automatiquement
- Compilation réussie
- Application s'exécute sans erreurs

### Étape 4 : Test Qt Creator IDE

```bash
# Ouvrir le projet dans Qt Creator
cd my-test-app
qtcreator .
```

**Résultat attendu dans Qt Creator** :
- Le projet s'ouvre sans erreurs
- CMake détecte automatiquement Qt6
- Un kit de build est créé automatiquement
- Clic sur le bouton Play compile et lance l'application

## Points critiques de la configuration

### Variables d'environnement essentielles

Pour que Qt Creator détecte Qt6 automatiquement, 3 variables sont essentielles :

1. **CMAKE_PREFIX_PATH** : Contient tous les chemins Qt6
   ```
   /nix/store/*-qtbase-6.*/:/nix/store/*-qtdeclarative-*/:...
   ```

2. **Qt6_DIR** : Chemin vers les fichiers CMake de Qt6
   ```
   /nix/store/*-qtbase-*/lib/cmake/Qt6
   ```

3. **QT_QPA_PLATFORM_PLUGIN_PATH** : Pour le rendu graphique
   ```
   /nix/store/*-qtbase-*/lib/qt-6.*/plugins
   ```

Ces variables sont automatiquement définies par le module `qt-quick.nix`.

### CMakeLists.txt généré

Le script crée un CMakeLists.txt optimisé pour NixOS :

```cmake
# Auto-export compile_commands.json pour clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Détection automatique de Qt6 via CMAKE_PREFIX_PATH et Qt6_DIR
find_package(Qt6 REQUIRED COMPONENTS Quick Widgets SerialPort)
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

# Build configuration
qt_add_executable(app src/main.cpp)
qt_add_qml_module(app ...)
```

## Cas d'usage courants

### 1. Développement simple avec Qt Creator

```bash
new-qt-project my-app
cd my-app
qtcreator .
# Qt Creator détecte Qt6 automatiquement
# Clic Play → compilation et exécution
```

### 2. Développement avec Neovim + clangd LSP

```bash
new-qt-project my-app
cd my-app
nvim src/main.cpp
# clangd fonctionne automatiquement via CMAKE_PREFIX_PATH
# LSP : gd (go def), gr (refs), K (signature), <leader>ca (actions)
```

### 3. Compilation en ligne de commande

```bash
new-qt-project my-app
cd my-app
./build.sh
# Ou manuellement :
cmake -B build -G Ninja
ninja -C build
./build/app
```

### 4. Preview QML en temps réel

```bash
new-qt-project my-app
cd my-app/ui
qml Main.qml  # Live preview QML, éditable avec éditeur externe
```

## Vérification post-déploiement

Checklist à vérifier après le rebuild :

- [ ] `which qtcreator` retourne un chemin valide
- [ ] `echo $CMAKE_PREFIX_PATH` contient `/nix/store/*-qtbase-*`
- [ ] `echo $Qt6_DIR` est défini
- [ ] `new-qt-project test-app` crée le projet sans erreurs
- [ ] `cd test-app && ./build.sh` compile sans erreurs CMake
- [ ] `qtcreator .` ouvre le projet sans erreurs
- [ ] Qt Creator détecte automatiquement un kit de build
- [ ] Clang dans Qt Creator ne montre pas d'erreurs sur headers Qt

## Troubleshooting rapide

| Problème | Cause | Solution |
|----------|-------|----------|
| Qt Creator pas trouvé | Module non appliqué | `sudo nixos-rebuild switch --flake .#nixos` |
| CMake "Could NOT find Qt6" | CMAKE_PREFIX_PATH vide | Vérifier env vars : `echo $CMAKE_PREFIX_PATH` |
| Qt Creator no kit created | Qt6_DIR manquant | Vérifier : `echo $Qt6_DIR` |
| clangd headers not found | compile_commands.json manquant | Régénérer : `cmake -B build -G Ninja` |
| .pro file not created | Script cache | `home-manager switch --flake .` |

## Documentation complète

Voir **SETUP-QT-CREATOR.md** pour :
- Guide d'installation détaillé
- Configuration manuelle avancée
- Intégration complète clangd
- Troubleshooting exhaustif
- Références Qt6/CMake/Qt Creator

## Fichiers affectés par ce déploiement

| Fichier | Changement | Type |
|---------|-----------|------|
| `modules/dev/qt-quick.nix` | Ajout qtcreator, variables env, packages | Config NixOS |
| `home/mae.nix` | Script new-qt-project amélioré | Config Home Manager |
| `SETUP-QT-CREATOR.md` | Nouvelle documentation | Documentation |
| `test-qt-setup.sh` | Nouveau script de test | Outils |

## Rollback

Si vous devez revenir en arrière :

```bash
# Revenir au commit précédent
git revert ea75617

# Ou restaurer le module previous
git checkout HEAD~1 modules/dev/qt-quick.nix

# Rebuild
sudo nixos-rebuild switch --flake .#nixos
```

