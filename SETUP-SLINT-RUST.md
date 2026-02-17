# Setup Slint + Rust sur NixOS

## Contexte

Configuration NixOS flakes existante dans `~/nixos-config`. L'utilisateur `mae` est un dev C#/WPF + C embarqué (ESP32) qui migre vers **Slint + Rust** pour le développement desktop cross-platform léger. Il souhaite aussi garder la possibilité de dev embarqué ESP32 en Rust.

## Objectif

1. Créer un module `modules/dev/slint-rust.nix` avec le toolchain Rust + dépendances Slint
2. Ajouter le input `rust-overlay` dans `flake.nix` pour un toolchain Rust à jour
3. Configurer l'éditeur (extension Slint pour VS Code, slint-lsp pour Neovim)
4. Créer un script helper pour initialiser un projet Slint rapidement
5. Optionnellement retirer `rider.nix` et `qtcreator.nix` des imports (commenter, pas supprimer)

## Architecture cible

```
modules/dev/slint-rust.nix    # Nouveau module
flake.nix                      # Ajouter rust-overlay input
hosts/nixos/default.nix        # Importer le nouveau module
home/mae.nix                   # Script helper new-slint-project
```

## Instructions détaillées

### 1. Ajouter rust-overlay dans `flake.nix`

Ajouter dans `inputs` :

```nix
rust-overlay = {
  url = "github:oxalica/rust-overlay";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Ajouter l'overlay dans la config nixos (dans `outputs`, au niveau de `modules`) :

```nix
({ config, pkgs, ... }: {
  nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
})
```

Passer `inputs` à `specialArgs` (déjà fait dans la config actuelle).

### 2. Créer `modules/dev/slint-rust.nix`

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Rust toolchain via overlay (stable + rust-analyzer)
    (rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
      targets = [
        "x86_64-unknown-linux-gnu"
        # Décommenter pour cross-compile ESP32 (Xtensa non supporté par rustup standard)
        # Utiliser esp-rs/rust-build pour ESP32 Xtensa
        # "riscv32imc-unknown-none-elf"  # Pour ESP32-C3 (RISC-V)
      ];
    })
    cargo-edit        # cargo add/rm/upgrade
    cargo-watch       # Recompilation auto sur changement

    # Slint
    slint-lsp         # Language server pour éditeurs

    # Dépendances build Slint (backend Winit + renderer Femtovg)
    cmake
    pkg-config
    fontconfig
    freetype
    libxkbcommon
    libGL

    # Backend Wayland (recommandé sur NixOS/Hyprland)
    wayland
    wayland-protocols
    wayland-scanner

    # Backend X11 (fallback)
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi

    # Communication série (microcontrôleurs)
    # serialport-rs utilise libudev
    udev
  ];

  # Variables d'environnement pour que les crates Rust trouvent les libs
  environment.sessionVariables = {
    # pkg-config doit trouver les .pc des dépendances
    PKG_CONFIG_PATH = pkgs.lib.makeSearchPath "lib/pkgconfig" [
      pkgs.fontconfig.dev
      pkgs.freetype.dev
      pkgs.libxkbcommon.dev
      pkgs.wayland.dev
      pkgs.libGL.dev
    ];

    # Linker doit trouver les .so
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.fontconfig
      pkgs.freetype
      pkgs.libxkbcommon
      pkgs.libGL
      pkgs.wayland
      pkgs.xorg.libX11
      pkgs.xorg.libXcursor
      pkgs.xorg.libXrandr
      pkgs.xorg.libXi
      pkgs.vulkan-loader  # Si Slint utilise le renderer Skia
    ];
  };
}
```

### 3. Importer le module dans `hosts/nixos/default.nix`

Ajouter dans la liste `imports` :

```nix
../../modules/dev/slint-rust.nix
```

Optionnellement commenter les anciens modules :

```nix
# ../../modules/dev/rider.nix       # Remplacé par Slint + Rust
# ../../modules/dev/qtcreator.nix    # Remplacé par Slint + Rust
```

### 4. Ajouter un script helper dans `home/mae.nix`

Ajouter dans `home.packages` un script `new-slint-project` :

```nix
(pkgs.writeShellScriptBin "new-slint-project" ''
  #!/usr/bin/env bash
  if [ -z "$1" ]; then
    echo "Usage: new-slint-project <nom-du-projet>"
    exit 1
  fi

  PROJECT_NAME="$1"

  cargo init "$PROJECT_NAME"
  cd "$PROJECT_NAME"

  # Ajouter Slint comme dépendance
  cargo add slint

  # Créer le fichier UI Slint
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

  # Créer le main.rs
  cat > src/main.rs << 'RUST'
  slint::include_modules!();

  fn main() {
      let app = App::new().unwrap();
      app.run().unwrap();
  }
  RUST

  # Build.rs pour compiler le fichier .slint
  cat > build.rs << 'RUST'
  fn main() {
      slint_build::compile("ui/app.slint").unwrap();
  }
  RUST

  # Ajouter slint-build comme build-dependency
  cargo add slint-build --build

  echo ""
  echo "Projet '$PROJECT_NAME' créé avec succès !"
  echo ""
  echo "Commandes utiles :"
  echo "  cd $PROJECT_NAME"
  echo "  cargo run                    # Lancer l'app"
  echo "  slint-viewer ui/app.slint    # Preview live de l'UI"
  echo "  cargo watch -x run           # Recompiler auto"
'')
```

### 5. Configuration éditeur

#### VS Code (déjà installé via vscode.fhs)

L'extension **Slint** (id: `slint.slint`) fournit :
- Coloration syntaxique `.slint`
- **Live preview** intégré dans VS Code
- Autocomplétion via slint-lsp
- Go to definition

L'utilisateur devra installer l'extension manuellement depuis VS Code.

#### Neovim (LazyVim déjà configuré)

Si l'utilisateur veut le support Slint dans Neovim, créer `home/nvim/lua/plugins/slint.lua` :

```lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        slint_lsp = {},
      },
    },
  },
  -- Coloration syntaxique Slint
  {
    "slint-ui/vim-slint",
    ft = "slint",
  },
}
```

### 6. Preview live

La preview Slint fonctionne de 2 manières :
- **`slint-viewer ui/app.slint`** : Commande standalone, hot-reload sur sauvegarde du fichier
- **Extension VS Code Slint** : Preview intégrée dans un panneau VS Code

Les deux fonctionnent sans configuration supplémentaire une fois le module installé.

### 7. Rebuild

```bash
# Mettre à jour le flake.lock avec le nouveau input
nix flake update --flake ~/nixos-config

# Rebuild
nh os switch ~/nixos-config
# ou
sudo nixos-rebuild switch --flake ~/nixos-config#nixos
```

### 8. Test après install

```bash
# Vérifier le toolchain
rustc --version
cargo --version
slint-viewer --version

# Créer un projet test
new-slint-project test-slint
cd test-slint
cargo run

# Preview live dans un autre terminal
slint-viewer ui/app.slint
```

## Notes importantes

- Le module `rider.nix` actuel définit des `LD_LIBRARY_PATH` et `sessionVariables`. Si les deux modules coexistent, les variables seront mergées par NixOS (pas de conflit). Mais si Rider n'est plus utilisé, le commenter allégera le système.
- `rust-overlay` fournit des toolchains plus récentes que `pkgs.cargo`/`pkgs.rustc` de nixpkgs, et permet d'ajouter facilement des targets de cross-compilation.
- Pour le dev ESP32 en Rust (pas via ESP-IDF C), il faudra un setup séparé avec `esp-rs/rust-build` car les ESP32 Xtensa ne sont pas dans le toolchain standard. Les ESP32-C3/C6 (RISC-V) fonctionnent avec le target `riscv32imc-unknown-none-elf`.
- `slint-lsp` est dans nixpkgs, pas besoin de le compiler à la main.
- Slint utilise par défaut le backend **Winit + Femtovg (OpenGL)**. Sur Wayland/Hyprland ça fonctionne nativement.
