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

  # ── Hardware ────────────────────────────────────────────────
  usb-reset = "sudo modprobe -r xhci_pci && sudo modprobe xhci_pci";

  # ── Nettoyage ──────────────────────────────────────────────
  clean = "nh clean all";

  # ── Aide ────────────────────────────────────────────────────
  help-cmd = ''
    echo ""
    echo "  ── NixOS ──────────────────────────────────────"
    echo "  update          Rebuild la config (sans mise à jour)"
    echo "  upgrade         MAJ quotidienne (Firefox, VSCode, Zen…)"
    echo "  upgrade-system  MAJ système (nixpkgs + home-manager)"
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
