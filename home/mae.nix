{ config, pkgs, inputs, ... }:

{
  home.username = "mae";
  home.homeDirectory = "/home/mae";

  home.packages = with pkgs; [
    mpv
    imv
    btop
    fastfetch
    tree
    
    # LazyVim dependencies
    git
    gcc
    ripgrep
    fd
    lazygit
  ];

  # Neovim avec LazyVim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Config LazyVim sauvegardée
  xdg.configFile."nvim".source = ./nvim;

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
    
    shellAliases = import ./shell/aliases.nix;
    
    initContent = ''
      # ESP-IDF (décommenter après installation)
      # alias get_idf='. $HOME/esp/esp-idf/export.sh'
      
      # Fastfetch à l'ouverture du terminal
      fastfetch
    '';
  };

  # Fish shell
  programs.fish = {
    enable = true;
    shellAliases = import ./shell/aliases.nix;
    interactiveShellInit = ''
      # Fastfetch à l'ouverture du terminal
      fastfetch
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

  # Config niri
  home.file.".config/niri/config.kdl".source = ./niri/config.kdl;

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
