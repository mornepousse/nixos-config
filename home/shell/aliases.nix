{
  # Navigation
  ll = "ls -la";
  
  # NixOS
  update = "nh os switch ~/nixos-config";
  upgrade = "cd ~/nixos-config && nix flake update && nh os switch .";
  check-updates = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild build --flake .#nixos && nvd diff /run/current-system ./result; git restore flake.lock && rm -f result";

  # Git
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gp = "git push";

  # Nettoyage
  clean = "nh clean all";
}
