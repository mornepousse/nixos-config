{ config, pkgs, inputs, ... }:

{
  # Affinity v2 (Photo, Designer, Publisher) via Wine
  # https://github.com/mrshmllow/affinity-nix
  environment.systemPackages = [
    inputs.affinity-nix.packages.x86_64-linux.photo
    inputs.affinity-nix.packages.x86_64-linux.designer
    inputs.affinity-nix.packages.x86_64-linux.publisher
  ];
}
