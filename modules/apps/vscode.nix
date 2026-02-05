{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        # Nix
        jnoortheen.nix-ide
        
        # C/C++ (STM32, ESP32)
        ms-vscode.cpptools
        ms-vscode.cmake-tools
        
        # Python
        ms-python.python
        ms-python.vscode-pylance
        
        # Git
        eamodio.gitlens
        
        # Markdown
        yzhang.markdown-all-in-one
        
        # Utilitaires
        editorconfig.editorconfig
        
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        # PlatformIO (pour ESP32/STM32)
        {
          name = "platformio-ide";
          publisher = "platformio";
          version = "3.3.3";
          sha256 = "sha256-VcIgnGRi2rVdKWpQ/AaDKTP5zKj/GCBJsp0ZT+br3hY=";
        }
        # Cortex-Debug (pour STM32)
        {
          name = "cortex-debug";
          publisher = "marus25";
          version = "1.12.1";
          sha256 = "sha256-I0DBTooCXg3pez1EAu8I6i8mSDPvUYYrYpfO1p1kVjQ=";
        }
      ];
    })
  ];
}
