{ pkgs }:
[
  (pkgs.writeShellScriptBin "new-slint-project" ''
if [ -z "$1" ]; then
  echo "Usage: new-slint-project <nom-du-projet>"
  exit 1
fi

PROJECT_NAME="$1"

cargo init "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

cargo add slint

mkdir -p ui
cat > ui/app.slint << 'SLINT'
import { VerticalBox, Button, LineEdit } from "std-widgets.slint";

export component App inherits Window {
    title: "Mon App Slint";
    preferred-width: 600px;
    preferred-height: 400px;

    VerticalBox {
        Text {
            text: "Hello depuis Slint + Rust !";
            font-size: 24px;
            horizontal-alignment: center;
        }
        Button {
            text: "Cliquer ici";
            clicked => { debug("Bouton cliqué !"); }
        }
    }
}
SLINT

cat > src/main.rs << 'RUST'
slint::include_modules!();

fn main() {
    let app = App::new().unwrap();
    app.run().unwrap();
}
RUST

cat > build.rs << 'RUST'
fn main() {
    slint_build::compile("ui/app.slint").unwrap();
}
RUST

cargo add slint-build --build

echo ""
echo "Projet '$PROJECT_NAME' cree avec succes !"
echo ""
echo "Commandes utiles :"
echo "  cd $PROJECT_NAME"
echo "  cargo run                    # Lancer l'app"
echo "  slint-viewer ui/app.slint    # Preview live de l'UI"
echo "  cargo watch -x run           # Recompiler auto"
  '')

  (pkgs.writeShellScriptBin "new-qt-project" ''
if [ -z "$1" ]; then
  echo "Usage: new-qt-project <nom-du-projet>"
  exit 1
fi

PROJECT_NAME="$1"

mkdir -p "$PROJECT_NAME/ui"
mkdir -p "$PROJECT_NAME/src"
cd "$PROJECT_NAME" || exit 1

cat > CMakeLists.txt << 'CMAKE'
cmake_minimum_required(VERSION 3.20)
project(app LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets SerialPort)
qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

qt_add_executable(app src/main.cpp)

qt_add_qml_module(app
    URI App
    VERSION 1.0
    QML_FILES ui/Main.qml
)

target_link_libraries(app PRIVATE
    Qt6::Quick
    Qt6::Widgets
    Qt6::SerialPort
)
CMAKE

cat > src/main.cpp << 'CPP'
#include <QApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;

    using namespace Qt::StringLiterals;
    const QUrl url(u"qrc:/qt/qml/App/ui/Main.qml"_s);
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
CPP

cat > ui/Main.qml << 'QML'
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 600
    height: 400
    title: "Mon App Qt Quick"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Hello depuis Qt Quick !"
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        Button {
            text: "Cliquer ici"
            Layout.alignment: Qt.AlignHCenter
            onClicked: console.log("Bouton clique !")
        }
    }
}
QML

cat > .clangd << 'CLANGD'
# Configuration clangd pour projets Qt6
CompileFlags:
  Add:
    - -fPIC
    - -Wno-unknown-warning-option
  Remove:
    # Désactiver les warnings Qt (macros, MOC, etc.)
    - -Wsuggest-override
    - -Woverloaded-virtual
InlayHints:
  DeducedTypes: true
  Designators: true
  BlockEnd: false
CLANGD

# Qt Creator .pro: configuration de Qt Creator
cat > "''${PROJECT_NAME}.pro" << 'QTPRO'
# Fichier Qt Creator pour reconnaissance du projet
TEMPLATE = app
QT += quick widgets serialport
LANGUAGE = C++17
CONFIG += c++17
SOURCES += src/main.cpp
QML_FILES += ui/Main.qml
QTPRO

mkdir -p build

# Créer un script de build qui copie compile_commands.json à la racine (pour clangd/Neovim)
cat > build.sh << 'BUILDSCRIPT'
#!/bin/bash
set -e
echo "Configuration CMake..."
cmake -B build -G Ninja
echo "Compilation..."
ninja -C build
echo "Copie compile_commands.json à la racine pour clangd/Neovim..."
cp build/compile_commands.json .
echo "✓ Compilation reussie !"
BUILDSCRIPT
chmod +x build.sh

echo ""
echo "Projet '$PROJECT_NAME' cree avec succes !"
echo ""
echo "Commandes utiles :"
echo "  cd $PROJECT_NAME"
echo "  qtcreator .                                    # Ouvrir dans Qt Creator"
echo "  ./build.sh                                     # Compiler (et configurer clangd)"
echo "  ./build/app                                    # Lancer"
echo "  qml ui/Main.qml                               # Preview live QML"
echo ""
echo "✓ Configuration Qt Creator, .clangd et build.sh generes"
  '')
]
