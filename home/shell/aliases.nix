{
  # ── Navigation ──────────────────────────────────────────────
  ll = "ls -la";

  # ── NixOS : rebuild (sans mise à jour) ─────────────────────
  update = "nh os switch ~/nixos-config";

  # ── NixOS : mises à jour segmentées ────────────────────────
  #
  #  upgrade        → quotidien    — Firefox, VSCode, Vesktop, Zen, Affinity…
  #  upgrade-system → 1-2x/mois   — nixpkgs + home-manager seuls (core système)
  #  upgrade-dev    → selon besoin — Rust toolchain, ESP-IDF
  #  upgrade-all    → occasionnel  — TOUS les inputs d'un coup
  #  check-updates  → preview      — liste les mises à jour sans appliquer (script)
  #
  upgrade        = "cd ~/nixos-config && nix flake update nixpkgs home-manager zen-browser affinity-nix && nh os switch .";
  upgrade-system = "cd ~/nixos-config && nix flake update nixpkgs home-manager && nh os switch .";
  upgrade-dev    = "cd ~/nixos-config && nix flake update rust-overlay nixpkgs-esp-dev && nh os switch .";
  upgrade-all    = "cd ~/nixos-config && nix flake update && nh os switch .";

  # ── Git ─────────────────────────────────────────────────────
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gp = "git push";

  # ── Nettoyage ──────────────────────────────────────────────
  clean = "nh clean all";
}
