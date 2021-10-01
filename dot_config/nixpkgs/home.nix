{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config.allowUnfree = true;
  };
in {
  home.packages = with pkgs; [
    # fonts
    dejavu_fonts
    nerdfonts
    noto-fonts
    noto-fonts-emoji
    siji
    weather-icons

    # terminals
    kitty
    termite

    # editors
    kakoune

    # utilities
    chezmoi
    dig
    feh
    flameshot
    htop
    neofetch
    networkmanager_dmenu
    sxiv
    unclutter
    unzip
    xclip

    # gui
    unstable._1password-gui
    discord
    firefox
    obsidian
    teams
    unstable.zoom-us

    # tools
    lsof
    pciutils
    usbutils

    # network
    tailscale
  ];

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "TwoDark";
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set -x EDITOR kak
        set fish_greeting
        cd && neofetch
      '';
    };

    git = {
      enable = true;
      userName = "bojo";
      userEmail = "bcj@alasconnect.com";
    };

    ssh = {
      enable = true;
    };
  };

  home.username = "bojo";
  home.homeDirectory = "/home/bojo";
  home.stateVersion = "21.05";
}
