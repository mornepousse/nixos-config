{
  # Navigation
  ll = "ls -la";
  
  # NixOS
  update = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
  upgrade = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild switch --flake .#nixos";
  check-updates = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild build --flake .#nixos && nix store diff-closures /run/current-system ./result; git restore flake.lock && rm -f result";
  
  # Git
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gp = "git push";
  
  # Nettoyage
  clean = "sudo nix-collect-garbage -d";
}
