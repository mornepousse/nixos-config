{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Qt Creator IDE (includes Qt dependencies)
    qtcreator

    # Compilation tools for C++ development
    gcc
    clang
    cmake
    ninja
    pkg-config
    gdb
    lldb

    # Build essentials
    binutils
    gnumake
    autoconf
    automake
    libtool

    # Useful dev tools
    git
    wget
    curl
    htop
  ];

}
