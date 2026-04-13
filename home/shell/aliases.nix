{
  # ── Navigation ──────────────────────────────────────────────
  ll = "ls -la";

  # ── NixOS : rebuild (sans mise à jour) ─────────────────────
  update = "nh os switch ~/nixos-config";

  # ── NixOS : mises à jour segmentées ────────────────────────
  #
  #  upgrade      → hebdo        — nixpkgs + home-manager (système + apps nixpkgs)
  #  upgrade-apps → quotidien    — flakes tiers (Zen, Affinity, KeSp, Claude Code)
  #  upgrade-dev  → selon besoin — Rust toolchain, ESP-IDF
  #  upgrade-all  → occasionnel  — TOUS les inputs d'un coup
  #  check-updates → preview     — liste les mises à jour sans appliquer (script)
  #
  upgrade      = "cd ~/nixos-config && nix flake update nixpkgs home-manager && nh os switch .";
  upgrade-apps = "cd ~/nixos-config && nix flake update zen-browser affinity-nix kesp-controller claude-code && nh os switch .";
  upgrade-dev  = "cd ~/nixos-config && nix flake update rust-overlay nixpkgs-esp-dev && nh os switch .";
  upgrade-all  = "cd ~/nixos-config && nix flake update && nh os switch .";

  # ── Git ─────────────────────────────────────────────────────
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gp = "git push";

  # ── Hardware ────────────────────────────────────────────────
  usb-reset = "sudo modprobe -r xhci_pci && sudo modprobe xhci_pci";

  # ── Nettoyage ──────────────────────────────────────────────
  clean = "nh clean all";

  # ── Aide ────────────────────────────────────────────────────
  help-cmd = ''
    echo ""
    echo "  ── NixOS ──────────────────────────────────────"
    echo "  update          Rebuild la config (sans mise à jour)"
    echo "  upgrade         MAJ système + apps (nixpkgs, hebdo)"
    echo "  upgrade-apps    MAJ flakes tiers (Zen, Affinity, KeSp…)"
    echo "  upgrade-dev     MAJ dev (Rust, ESP-IDF)"
    echo "  upgrade-all     MAJ tout"
    echo "  check-updates   Voir les MAJ dispo sans appliquer"
    echo "  clean           Nettoyage garbage collect"
    echo ""
    echo "  ── Git ────────────────────────────────────────"
    echo "  gs              git status"
    echo "  ga              git add"
    echo "  gc              git commit"
    echo "  gp              git push"
    echo ""
    echo "  ── Hardware ───────────────────────────────────"
    echo "  usb-reset       Reset USB (fix dock)"
    echo "  esp-shell       Shell ESP-IDF (ESP32)"
    echo "  code-esp        VSCode + ESP-IDF"
    echo ""
    echo "  ── Hyprland (Mod = Super) ────────────────────"
    echo "  Mod+Return      Terminal (Alacritty)"
    echo "  Mod+Space       Lanceur (Fuzzel)"
    echo "  Mod+B           Navigateur"
    echo "  Mod+E           Fichiers (Thunar)"
    echo "  Mod+Q           Fermer fenêtre"
    echo "  Mod+F           Plein écran"
    echo "  Mod+T           Flottant"
    echo "  Mod+V           Clipboard"
    echo "  Mod+Shift+M     Toggle écrans"
    echo "  Mod+Shift+U     Reset USB"
    echo "  Mod+Shift+W     Relancer waybar"
    echo ""
  '';
}
