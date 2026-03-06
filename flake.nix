{
  description = "NixOS configuration — Hyprland / Sway + waybar (Wayland)";

  inputs = {
    # ── Base (upgrade) ─────────────────────────────────────────
    # nixpkgs + home-manager : cœur du système, la plupart des paquets
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Apps tierces (upgrade) ────────────────────────────────
    # Navigateur Zen (basé Firefox) — mise à jour fréquente
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    # Suite Affinity (Photo/Designer/Publisher) via Wine
    affinity-nix = {
      url = "github:mrshmllow/affinity-nix";
    };

    # ── Toolchains dev (upgrade-dev) ──────────────────────────
    # Rust toolchain à jour via overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ESP-IDF pour développement ESP32 (tous les chips)
    nixpkgs-esp-dev = {
      url = "github:mirrexagon/nixpkgs-esp-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # Configuration pour morthinkpad (avec DisplayLink)
      morthinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/morthinkpad

          # Overlay rust-overlay pour toolchain Rust à jour
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mae = import ./home/mae.nix;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = "morthinkpad"; };
            home-manager.backupFileExtension = "backup";  # Sauvegarde les fichiers existants
          }
        ];
      };

      # Configuration pour x230t (sans DisplayLink)
      x230t = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/x230t

          # Overlay rust-overlay pour toolchain Rust à jour
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mae = import ./home/mae.nix;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = "x230t"; };
            home-manager.backupFileExtension = "backup";  # Sauvegarde les fichiers existants
          }
        ];
      };

      # Legacy: garder nixos comme alias à morthinkpad
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/morthinkpad

          # Overlay rust-overlay pour toolchain Rust à jour
          ({ config, pkgs, ... }: {
            nixpkgs.overlays = [ inputs.rust-overlay.overlays.default ];
          })

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mae = import ./home/mae.nix;
            home-manager.extraSpecialArgs = { inherit inputs; hostname = "morthinkpad"; };
            home-manager.backupFileExtension = "backup";  # Sauvegarde les fichiers existants
          }
        ];
      };
    };
  };
}
