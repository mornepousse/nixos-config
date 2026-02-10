{ config, pkgs, ... }:

{
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

  # Variables d'environnement pour .NET
  environment.variables = {
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";  # Désactive la télémétrie
  };
  environment.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.icu}/lib";
  };
}
