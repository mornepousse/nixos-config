# Qt Creator + Qt6 Quick sur NixOS

Ce guide configure Qt Creator pour fonctionner correctement avec Qt6 sur NixOS, avec support complet CMake, clangd LSP, et compilation sans problèmes de chemins.

## État actuel de la configuration

### Module NixOS (`modules/dev/qt-quick.nix`)

Le module configure automatiquement :

- **Qt6 complet** : qt6.full + tous les modules (qtbase, qtdeclarative, qttools, qtwayland, qtserialport, qtcharts, qtconnectivity, qtmultimedia)
- **Qt Creator 18.0+** : IDE complet avec détection automatique de Qt6
- **Outils de build** : cmake, ninja, gcc, make, pkg-config
- **Développement C++** : clang-tools (clangd LSP), lldb debugger
- **Variables d'environnement automatiques** :
  - `CMAKE_PREFIX_PATH` : Pointe vers tous les modules Qt6 et libGL
  - `Qt6_DIR` : Localisation des fichiers CMake de Qt6
  - `QT_PLUGIN_PATH` : Chemin vers les plugins Qt6
  - `QML2_IMPORT_PATH` : Chemin vers les imports QML
  - `QT_QPA_PLATFORM_PLUGIN_PATH` : Pour affichage graphique Qt Creator

### Script `new-qt-project` (home/mae.nix)

Crée un nouveau projet Qt Quick prêt à l'emploi avec :

- **Structure de dossiers** : `src/`, `ui/`, `build/`
- **CMakeLists.txt optimisé** :
  - `CMAKE_EXPORT_COMPILE_COMMANDS ON` pour clangd/Neovim
  - `find_package(Qt6 REQUIRED)` avec les bons composants
  - `qt_add_qml_module()` pour gestion QML automatique
  - Policies Qt6 pour éviter warnings

- **Fichiers de démarrage** :
  - `src/main.cpp` : Application Qt Quick prête
  - `ui/Main.qml` : Interface QML basique
  - `.clangd` : Configuration clangd pour LSP (désactive warnings Qt)
  - `test-app.pro` : Fichier .pro pour Qt Creator recognition
  - `build.sh` : Script de compilation (cmake + ninja)

## Installation

### 1. Appliquer la configuration NixOS

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

Cela installera Qt Creator 18.0+ et tous les dépendances Qt6.

### 2. Vérifier l'installation

```bash
# Vérifier que QtCreator est disponible
which qtcreator

# Vérifier que CMAKE_PREFIX_PATH contient Qt6
echo $CMAKE_PREFIX_PATH

# Vérifier que clangd est disponible (pour Neovim LSP)
which clangd

# Vérifier que cmake trouve Qt6
cmake -S /tmp/test-qt-quick -B /tmp/test-qt-quick/build 2>&1 | grep -i qt6
```

## Créer un nouveau projet Qt6

### Avec le script helper

```bash
new-qt-project mon-app
cd mon-app
```

Le script crée :
- Structure de dossiers complète
- CMakeLists.txt avec find_package(Qt6) automatique
- Fichiers source C++ et QML
- Configuration pour Qt Creator et clangd

### Manuellementsans le script

```bash
mkdir mon-app && cd mon-app
mkdir -p src ui build

# CMakeLists.txt minimal
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(myapp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets)
qt_policy(SET QTP0001 NEW)

qt_add_executable(myapp src/main.cpp)
qt_add_qml_module(myapp
    URI MyApp
    VERSION 1.0
    QML_FILES ui/Main.qml
)
target_link_libraries(myapp PRIVATE Qt6::Quick Qt6::Widgets)
EOF
```

## Ouvrir dans Qt Creator

### Méthode 1 : Ouvrir depuis Qt Creator GUI

```bash
qtcreator .
```

Qt Creator détectera automatiquement :
- CMakeLists.txt
- Qt6 (via CMAKE_PREFIX_PATH et Qt6_DIR)
- Kits et compilateurs

### Méthode 2 : Configuration manuelle

1. Lancer `qtcreator`
2. **File → Open File or Project** → Sélectionner `CMakeLists.txt`
3. Qt Creator détecte automatiquement Qt6 et crée un profil de build
4. **Projects → Build & Run** pour configurer manuellement si besoin

## Compiler le projet

### Méthode 1 : Depuis Qt Creator

- Clic sur le bouton Play (▶) ou `Ctrl+R`
- Ou **Build → Run**

### Méthode 2 : Ligne de commande

```bash
cd mon-app

# Utiliser le script helper
./build.sh

# Ou manuellement
cmake -B build -G Ninja
ninja -C build

# Lancer
./build/myapp
```

## Utiliser clangd dans Neovim

Le CMakeLists.txt génère automatiquement `compile_commands.json` (via `CMAKE_EXPORT_COMPILE_COMMANDS ON`), que clangd utilise pour l'intellisense.

```bash
# Dans le dossier du projet
nvim src/main.cpp

# clangd lit compile_commands.json automatiquement
# LSP disponible :
#   K = signature/doc
#   gd = aller à la définition
#   gr = references
#   <leader>ca = code actions
```

**Important** : Après un `cmake -B build`, clangd trouve automatiquement le fichier.

## Troubleshooting

### Qt Creator ne trouve pas Qt6

**Symptôme** : Message "No suitable Qt version found"

**Solutions** :

1. Vérifier `CMAKE_PREFIX_PATH` :
   ```bash
   echo $CMAKE_PREFIX_PATH
   ```
   Doit contenir `/nix/store/*qt6*`

2. Vérifier `Qt6_DIR` :
   ```bash
   echo $Qt6_DIR
   ```
   Doit être `/nix/store/...-qt6-qtbase-6.*/lib/cmake/Qt6`

3. Relancer Qt Creator après les variables d'environnement :
   ```bash
   # Forcer rechargement de l'environnement
   exec zsh  # ou exec fish
   qtcreator &
   ```

### CMake dit "Could NOT find Qt6"

**Symptôme** : Erreur CMake : `Could NOT find Qt6`

**Cause** : Les variables d'environnement ne sont pas chargées

**Solution** :

```bash
# Rechargement de l'environnement
exec zsh

# Ou spécifier explicitement
cmake -B build -G Ninja -DQt6_DIR=$Qt6_DIR
```

### clangd ne voit pas les headers Qt6

**Symptôme** : Erreur "Unknown type name 'QApplication'" dans Neovim

**Causes possibles** :

1. `compile_commands.json` manquant
   ```bash
   # Régénérer
   cmake -B build -G Ninja
   cp build/compile_commands.json .
   ```

2. clangd ne lit pas .clangd
   - Vérifier `.clangd` existe à la racine du projet
   - Vérifier que clangd est à jour : `clangd --version`

### Warnings Qt lors de la compilation

**Symptôme** : Warnings sur `MOC`, `Woverloaded-virtual`, etc.

**Solution** : Le fichier `.clangd` du script désactive ces warnings automatiquement.

Si vous créez manuellement un projet, ajoutez au `.clangd` :

```yaml
CompileFlags:
  Add:
    - -fPIC
    - -Wno-unknown-warning-option
  Remove:
    - -Wsuggest-override
    - -Woverloaded-virtual
```

## Cas d'usage typique

```bash
# 1. Créer projet
new-qt-project my-app
cd my-app

# 2. Ouvrir dans Qt Creator (auto-détecte Qt6)
qtcreator .

# 3. Compiler depuis Qt Creator (bouton Play)
# Ou ligne de commande :
./build.sh

# 4. Développer avec Neovim + clangd LSP
nvim src/main.cpp

# 5. Preview QML en temps réel
qml ui/Main.qml

# 6. Distribution (créer AppImage, etc.)
```

## Fichiers de configuration importants

| Fichier | Rôle |
|---------|------|
| `modules/dev/qt-quick.nix` | Configuration NixOS (Qt6, QtCreator, variables env) |
| `home/mae.nix` | Script `new-qt-project` pour initialiser projets |
| `.clangd` | Configuration clangd pour LSP (créé par new-qt-project) |
| `CMakeLists.txt` | Configuration CMake (créée par new-qt-project) |
| `compile_commands.json` | Généré par cmake, utilisé par clangd (auto-copié par build.sh) |

## Références

- [Qt6 Documentation](https://doc.qt.io/qt-6/)
- [CMake Qt6 Integration](https://doc.qt.io/qt-6/cmake-manual.html)
- [Qt Creator Manual](https://doc.qt.io/qtcreator/)
- [clangd Configuration](https://clangd.llvm.org/config)
- [NixOS Qt6](https://nixos.wiki/wiki/Qt)

