{ pkgs }:
let
  glib = pkgs.glib;
in
[
  (pkgs.writeShellScriptBin "setup-rclone-nas" ''
    mkdir -p ~/.config/rclone

    # Créer la config rclone pour Synology
    cat > ~/.config/rclone/rclone.conf << 'EOF'
[nas]
type = smb
host = 192.168.1.11
user = mae
pass = ''${RCLONE_SMB_PASS:-}
domain =
EOF

    # Demander le password s'il n'est pas défini
    if [ -z "$RCLONE_SMB_PASS" ]; then
      read -sp "Entrez le password SMB pour mae: " PASS
      echo ""
      sed -i "s|pass = |pass = $PASS|" ~/.config/rclone/rclone.conf
    fi

    chmod 600 ~/.config/rclone/rclone.conf
    echo "✓ Config rclone créée dans ~/.config/rclone/rclone.conf"
    echo ""
    echo "Montage: rclone mount nas:/FULLACCESS ~/mnt/nas/fullaccess --daemon"
    echo "Démont: fusermount -u ~/mnt/nas/fullaccess"
  '')

  (pkgs.writeShellScriptBin "mount-nas" ''
    mkdir -p $HOME/mnt/nas
    ${glib}/bin/gio mount smb://mae@192.168.1.11/FULLACCESS
    sleep 1
    rm -f $HOME/mnt/nas/fullaccess 2>/dev/null
    ln -sf '/run/user/1000/gvfs/smb-share:server=192.168.1.11,share=fullaccess,user=mae' $HOME/mnt/nas/fullaccess
    echo "✓ NAS monté sur $HOME/mnt/nas/fullaccess"
  '')
]
