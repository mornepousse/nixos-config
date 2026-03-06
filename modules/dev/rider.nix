{ config, pkgs, ... }:

{
  # nix-ld : libs nécessaires aux binaires non-NixOS (libSkiaSharp, Avalonia, etc.)
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    fontconfig.lib
    freetype
    libGL
    libGLU
    libxkbcommon
    icu
    zlib
    libX11
    libxcb
    libXext
    libXrender
    libXrandr
    libXi
    libXcursor
    libXinerama
    libxxf86vm
    libice
    libsm
    libxcomposite
    libxdamage
    libxfixes
    libxtst
    libxau
    libxdmcp
  ];

  environment.systemPackages = with pkgs; [
    # JetBrains Rider - IDE pour .NET/C#
    jetbrains.rider
    
    # SDK .NET (nécessaire pour Rider)
    
    #dotnet-sdk_9  # .NET 9 (décommenter si besoin)
    dotnet-sdk_10
    # Runtime .NET (optionnel, inclus dans le SDK)
    dotnet-runtime_9
    dotnet-runtime_10
    
    # Outils complémentaires
    # omnisharp-roslyn  # Language server C# (intégré dans Rider)

# Required libraries for Avalonia and X11
    libxcb
    libX11
    libXrandr
    libXinerama
    libXi
    libXxf86vm
    libXcursor
    libXext
    libXrender
    pkg-config
    xorg.libXxf86vm
    
    # ICU (Unicode support)
    icu

    # OpenGL support
    fontconfig
    freetype
    libGL
    libxkbcommon

    # Other common build tools
    gcc
    gnumake
    pkg-config
    git

    # Optional but useful
    just
    direnv

  ];

  # Variables .NET (pas de conflit, clés uniques)
  environment.variables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
  };

  # Symlink pour que Rider trouve dotnet à /usr/share/dotnet (son chemin par défaut)
  system.activationScripts.dotnet-symlink = ''
    mkdir -p /usr/share
    ln -sfn ${pkgs.dotnet-sdk_10}/share/dotnet /usr/share/dotnet
  '';

  # LD_LIBRARY_PATH via sessionVariables (liste) : NixOS concatène les listes
  # de plusieurs modules sans conflit, contrairement à environment.variables (string).
  # Nécessaire pour que libSkiaSharp.so et Avalonia (bundlés par NuGet) trouvent leurs dépendances.
  environment.sessionVariables = {
    LD_LIBRARY_PATH = map (pkg: "${pkg}/lib") [
      pkgs.stdenv.cc.cc.lib   # libstdc++, libgcc_s
      pkgs.icu
      pkgs.fontconfig.lib     # .lib output contient libfontconfig.so.1 (pas .bin)
      pkgs.freetype
      pkgs.libGL
      pkgs.libGLU
      pkgs.libxkbcommon
      pkgs.zlib
      # X11 complet pour Avalonia
      pkgs.libX11
      pkgs.libxcb
      pkgs.libXrandr
      pkgs.libXinerama
      pkgs.libXi
      pkgs.libXcursor
      pkgs.libXext
      pkgs.libXrender
      pkgs.libxxf86vm
      pkgs.libice
      pkgs.libsm
      pkgs.libxcomposite
      pkgs.libxdamage
      pkgs.libxfixes
      pkgs.libxtst
      pkgs.libxau
      pkgs.libxdmcp
    ];
  };
}
