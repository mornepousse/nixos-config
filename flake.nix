{
  description = "NixOS configuration for mae - Sway + waybar + SDDM";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-esp-dev = {
      url = "github:mirrexagon/nixpkgs-esp-dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
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
            home-manager.extraSpecialArgs = { inherit inputs; };
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
            home-manager.extraSpecialArgs = { inherit inputs; };
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
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.backupFileExtension = "backup";  # Sauvegarde les fichiers existants
          }
        ];
      };
    };
  };
}
