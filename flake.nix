{
  description = "NixOS configuration for mae - niri + quickshell + ly";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Quickshell (à activer plus tard quand on configurera la bar)
    # quickshell = {
    #   url = "github:quickshell-mirror/quickshell";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/nixos

        # Home-manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.mae = import ./home/mae.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
