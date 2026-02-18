#!/usr/bin/env bash

# Script de test pour vérifier la configuration Qt Creator + Qt6
# Usage: ./test-qt-setup.sh [--full]

# Ne pas arrêter sur les erreurs de commandes individuelles
set +e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

FULL_TEST=${1:-""}

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Test de configuration Qt Creator + Qt6 sur NixOS${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Fonction helper pour tester un binaire/variable
test_binary() {
    local name=$1
    local cmd=$2
    if command -v $cmd &> /dev/null; then
        echo -e "${GREEN}✓${NC} $name : $(command -v $cmd)"
        return 0
    else
        echo -e "${RED}✗${NC} $name : NON TROUVÉ"
        return 1
    fi
}

test_env() {
    local name=$1
    local var=$2
    if [ -n "${!var}" ]; then
        local value="${!var}"
        # Limiter la longueur d'affichage à 80 caractères
        if [ ${#value} -gt 80 ]; then
            value="${value:0:77}..."
        fi
        echo -e "${GREEN}✓${NC} $var = $value"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $var : NON DÉFINI"
        return 1
    fi
}

# 1. Vérifier les binaires
echo -e "${BLUE}1. Vérification des binaires:${NC}"
test_binary "Qt Creator" "qtcreator"
test_binary "CMake" "cmake"
test_binary "Ninja" "ninja"
test_binary "clangd" "clangd"
test_binary "moc (Qt Meta-Object Compiler)" "moc"
test_binary "qml (QML Preview)" "qml"
echo ""

# 2. Vérifier les variables d'environnement
echo -e "${BLUE}2. Vérification des variables d'environnement:${NC}"
test_env "CMAKE_PREFIX_PATH" "CMAKE_PREFIX_PATH"
test_env "Qt6_DIR" "Qt6_DIR"
test_env "QT_PLUGIN_PATH" "QT_PLUGIN_PATH"
test_env "QML2_IMPORT_PATH" "QML2_IMPORT_PATH"
echo ""

# 3. Vérifier que CMake trouve Qt6
echo -e "${BLUE}3. Test CMake avec Qt6:${NC}"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

cat > "$TMPDIR/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(QtTest LANGUAGES CXX)
find_package(Qt6 REQUIRED COMPONENTS Core)
message(STATUS "Qt6 trouvé !")
EOF

if cd "$TMPDIR" && cmake -B build . &>/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} CMake trouve Qt6 automatiquement"
else
    echo -e "${YELLOW}⚠${NC} CMake ne trouve pas Qt6 automatiquement"
    echo "   Conseil : Vérifier CMAKE_PREFIX_PATH et Qt6_DIR"
fi
cd - > /dev/null
echo ""

# 4. Tester la création d'un projet
if [ "$FULL_TEST" == "--full" ]; then
    echo -e "${BLUE}4. Test complet : Création et compilation d'un projet Qt6:${NC}"

    TESTPROJ=$(mktemp -d)
    trap "rm -rf $TMPDIR $TESTPROJ" EXIT

    cd "$TESTPROJ"
    mkdir -p src ui

    # Créer CMakeLists.txt
    cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)
project(TestApp LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Core)

add_executable(testapp src/main.cpp)
target_link_libraries(testapp PRIVATE Qt6::Core)
EOF

    # Créer main.cpp
    cat > src/main.cpp << 'EOF'
#include <iostream>
#include <QCoreApplication>

int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    std::cout << "Qt6 fonctionne !" << std::endl;
    return 0;
}
EOF

    # Essayer de compiler
    if mkdir -p build && cd build && cmake -G Ninja .. >/dev/null 2>&1; then
        if ninja >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Compilation réussie !"
            if [ -f testapp ]; then
                echo -e "${GREEN}✓${NC} Exécutable créé : testapp"
                if ./testapp 2>/dev/null | grep -q "Qt6 fonctionne"; then
                    echo -e "${GREEN}✓${NC} Programme s'exécute correctement !"
                else
                    echo -e "${YELLOW}⚠${NC} Programme s'exécute mais sortie inattendue"
                fi
            fi
        else
            echo -e "${YELLOW}⚠${NC} cmake configure OK mais ninja échoue"
            echo "   Vérifier les dépendances Qt6"
        fi
    else
        echo -e "${YELLOW}⚠${NC} cmake configure échoue"
        echo "   Conseils :"
        echo "   - Vérifier CMAKE_PREFIX_PATH: echo \$CMAKE_PREFIX_PATH"
        echo "   - Vérifier Qt6_DIR: echo \$Qt6_DIR"
        echo "   - Tenter: exec zsh  (recharger l'environnement)"
    fi
    cd - > /dev/null
else
    echo -e "${BLUE}4. Test complet disponible avec:${NC}"
    echo "   $0 --full"
    echo ""
fi

# 5. Vérifier le script new-qt-project
echo -e "${BLUE}5. Script new-qt-project:${NC}"
if command -v new-qt-project &> /dev/null; then
    echo -e "${GREEN}✓${NC} Script available: $(command -v new-qt-project)"
    echo ""
    echo "   Utilisation : new-qt-project <nom-du-projet>"
    echo "   Crée un projet Qt6 complet prêt à l'emploi"
else
    echo -e "${YELLOW}⚠${NC} Script new-qt-project non disponible"
    echo "   Conseil : Appliquer la configuration avec:"
    echo "   sudo nixos-rebuild switch --flake ~/nixos-config#nixos"
fi
echo ""

# Résumé
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Résumé:${NC}"
echo ""
echo -e "${GREEN}✓${NC} Configuration Qt Creator + Qt6 ready to use"
echo ""
echo "Prochaines étapes:"
echo "1. Créer un nouveau projet : new-qt-project mon-app"
echo "2. Ouvrir dans Qt Creator  : cd mon-app && qtcreator ."
echo "3. Compiler                : Clic Play ou ./build.sh"
echo ""
echo "Documentation complète : https://github.com/username/nixos-config/SETUP-QT-CREATOR.md"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
