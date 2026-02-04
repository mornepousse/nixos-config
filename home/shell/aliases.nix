{
  # Navigation
  ll = "ls -la";
  
  # NixOS
  update = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
  upgrade = "nix flake update ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
  
  # Git
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gp = "git push";
  
  # Nettoyage
  clean = "sudo nix-collect-garbage -d";
}
