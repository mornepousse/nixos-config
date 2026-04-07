{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Claude Code via flake sadjow/claude-code-nix (overlay, updates horaires)
    claude-code
  ];
}
