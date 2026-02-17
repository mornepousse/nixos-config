-- Clangd LSP configuration pour C++/Qt6
-- Supporte la découverte automatique de compile_commands.json et les chemins Qt

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          -- Options de clangd
          cmd = {
            "clangd",
            -- Désactiver les faux positifs sur les macros Qt (Q_OBJECT, signals, slots, etc.)
            "--header-insertion=iwyu",  -- Insert What You Use - meilleure gestion des includes
            "--query-driver=/nix/store/*/bin/cc",  -- Reconnaître le compilateur NixOS
            "--function-arg-placeholders=false",  -- Pas de placeholders pour les arguments
            "--enable-config",  -- Activer les fichiers .clangd au root du projet
            "--background-index",  -- Indexation en arrière-plan pour + de réactivité
          },
          init_options = {
            -- Suppression de faux positifs sur les macros Qt
            usePlaceholders = false,
            quoteIncludeResponse = true,
            completeUnimplementedMethods = false,
          },
          capabilities = {
            textDocument = {
              completion = {
                editsNearCursor = false,  -- Éviter les édits inutiles
              },
            },
          },
          settings = {
            -- Options supplémentaires si nécessaire
          },
          -- Chemins de recherche pour compile_commands.json
          -- clangd cherche automatiquement dans: ./build, ./cmake-build-*, ./out, ./venv
          -- On peut ajouter d'autres chemins ici
          root_dir = require("lspconfig.util").root_pattern(
            "compile_commands.json",
            "CMakeLists.txt",
            "CMakePresets.json",
            ".clangd",
            ".git"
          ),
        },
      },
    },
  },

  -- Treesitter: ajout des parseurs C/C++
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "cpp",
        "c",
        "cmake",
        "make",
      })
    end,
  },

  -- Mason: install clangd automatiquement (optionnel si déjà installé via Nix)
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- Note: clangd sera cherché depuis PATH (installé via modules/dev/qt-quick.nix)
      -- Mason peut le réinstaller pour la version manage, mais Nix primacy est préféré
      table.insert(opts.ensure_installed, "cmake")  -- CMake LSP pour CMakeLists.txt
    end,
  },

  -- Diagnostic configuré via nvim-lspconfig automatiquement
}
