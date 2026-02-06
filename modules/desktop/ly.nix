{ config, pkgs, ... }:

{
  # greetd + tuigreet - Display manager TUI minimaliste
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri";
        user = "greeter";
      };
    };
  };
}
