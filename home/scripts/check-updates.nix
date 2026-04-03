{ pkgs }:
let
  parseScript = pkgs.writeText "parse-updates.awk" ''
    /Updated input/ {
      match($0, /Updated input .([^']+)'/, m)
      name = m[1]
      old_date = ""
      new_date = ""
      state = 1
    }
    state == 1 && /^    .github:/ {
      match($0, /\(([0-9]{4}-[0-9]{2}-[0-9]{2})\)/, d)
      old_date = d[1]
      state = 2
      next
    }
    state == 2 && /→/ {
      match($0, /\(([0-9]{4}-[0-9]{2}-[0-9]{2})\)/, d)
      new_date = d[1]
      cmd = "echo $(( ($(date -d \"" new_date "\" +%s) - $(date -d \"" old_date "\" +%s)) / 86400 ))"
      cmd | getline days
      close(cmd)
      printf "  %-20s %s  ->  %s  (%s jours)\n", name, old_date, new_date, days
      state = 0
    }
  '';
in
[
  (pkgs.writeShellScriptBin "check-updates" ''
    cd ~/nixos-config || exit 1
    cp flake.lock flake.lock.bak
    trap 'mv -f flake.lock.bak flake.lock' EXIT INT TERM

    echo ""
    echo "Recherche de mises à jour..."
    echo ""

    output=$(nix flake update 2>&1)

    echo "$output" | ${pkgs.gawk}/bin/awk -f ${parseScript}

    count=$(echo "$output" | grep -c "Updated input")
    echo ""
    if [ "$count" -eq 0 ]; then
      echo "Tout est à jour !"
    else
      echo "$count input(s) avec mise à jour disponible"
      echo "Lance 'upgrade' ou 'upgrade-all' pour appliquer"
    fi
  '')
]
