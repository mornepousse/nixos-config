{ config, pkgs, inputs, ... }:

{
  home.username = "mae";
  home.homeDirectory = "/home/mae";

  home.packages = with pkgs; [
    mpv
    imv
    btop
    neofetch
    tree
  ];

  # Git config
  programs.git = {
    enable = true;
    settings = {
      user.name = "mae";
      user.email = "";
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      upgrade = "nix flake update ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
    };
    
    initContent = ''
      # ESP-IDF (décommenter après installation)
      # alias get_idf='. $HOME/esp/esp-idf/export.sh'
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Config quickshell
  xdg.configFile."quickshell/shell.qml".source = ./quickshell/shell.qml;

  # Config niri
  home.file.".config/niri/config.kdl".text = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
        }
        
        touchpad {
            tap
            natural-scroll
        }
    }
    
    output "eDP-1" {
        scale 1.0
    }
    
    layout {
        gaps 8
        border {
            width 2
        }
        focus-ring {
            width 2
        }
    }
    
    spawn-at-startup "mako"
    spawn-at-startup "quickshell"
    
    binds {
        Mod+Return { spawn "foot"; }
        Mod+D { spawn "fuzzel"; }
        Mod+Shift+Q { close-window; }
        
        Mod+H { focus-column-left; }
        Mod+J { focus-window-down; }
        Mod+K { focus-window-up; }
        Mod+L { focus-column-right; }
        
        Mod+Left { focus-column-left; }
        Mod+Down { focus-window-down; }
        Mod+Up { focus-window-up; }
        Mod+Right { focus-column-right; }
        
        Mod+Shift+H { move-column-left; }
        Mod+Shift+J { move-window-down; }
        Mod+Shift+K { move-window-up; }
        Mod+Shift+L { move-column-right; }
        
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        
        Mod+Shift+1 { move-window-to-workspace 1; }
        Mod+Shift+2 { move-window-to-workspace 2; }
        Mod+Shift+3 { move-window-to-workspace 3; }
        Mod+Shift+4 { move-window-to-workspace 4; }
        Mod+Shift+5 { move-window-to-workspace 5; }
        
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        
        Print { screenshot; }
        Mod+Print { screenshot-window; }
        
        XF86AudioRaiseVolume { spawn "pamixer" "-i" "5"; }
        XF86AudioLowerVolume { spawn "pamixer" "-d" "5"; }
        XF86AudioMute { spawn "pamixer" "-t"; }
        
        XF86MonBrightnessUp { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }
        
        Mod+Shift+E { quit; }
    }
  '';

  # Mako (notifications)
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  home.stateVersion = "26.05";
  programs.home-manager.enable = true;
}
