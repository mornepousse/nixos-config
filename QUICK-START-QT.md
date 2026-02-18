# Qt Creator + Qt6 - Quick Start Guide

## 1-Line Install & Test

```bash
cd ~/nixos-config && sudo nixos-rebuild switch --flake .#nixos && ./test-qt-setup.sh
```

## Après l'installation (3 commandes)

```bash
# 1. Créer un projet
new-qt-project hello-qt

# 2. Ouvrir dans Qt Creator
cd hello-qt && qtcreator .

# 3. Compiler & Lancer
./build.sh && ./build/app
```

## Ou avec Neovim + clangd

```bash
# 1. Créer un projet
new-qt-project hello-qt
cd hello-qt

# 2. Compiler une fois
./build.sh

# 3. Développer avec LSP
nvim src/main.cpp
# Ou : nvim ui/Main.qml
```

## Vérification rapide

```bash
# Vérifier l'installation
./test-qt-setup.sh

# Vérifier les variables d'environnement
echo "CMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH"
echo "Qt6_DIR=$Qt6_DIR"

# Vérifier les binaires
which qtcreator
which clangd
which moc
which cmake
```

## Fichiers importants

| Fichier | Description |
|---------|-------------|
| `modules/dev/qt-quick.nix` | Configuration NixOS Qt Creator + Qt6 |
| `home/mae.nix` | Script `new-qt-project` |
| `SETUP-QT-CREATOR.md` | Documentation complète (896 lignes) |
| `QT-CREATOR-DEPLOYMENT.md` | Guide de déploiement (267 lignes) |
| `test-qt-setup.sh` | Script de vérification |

## Prochaines étapes

1. **Installation** : `sudo nixos-rebuild switch --flake ~/nixos-config#nixos`
2. **Vérification** : `./test-qt-setup.sh`
3. **Premier projet** : `new-qt-project mon-app && cd mon-app && qtcreator .`
4. **Compilation** : Clic Play dans Qt Creator (ou `./build.sh`)

## Support

- Questions sur la configuration ? Voir `SETUP-QT-CREATOR.md`
- Problèmes ? Consulter la section Troubleshooting dans `QT-CREATOR-DEPLOYMENT.md`
- Bug report ? Vérifier `test-qt-setup.sh --full` pour debug détaillé

---

**Status** : ✅ Configuration ready to deploy
**Tested** : ✅ Script new-qt-project working
**Documentation** : ✅ Complete (1163 lines)

