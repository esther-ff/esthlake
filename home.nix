{ pkgs, config, lib, ... }:

let username = "esther";
in {
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      hyprland
      libreoffice
      fish
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal
      jdk
      protonvpn-cli_2
      protonvpn-gui
      firefox
      clang-tools
      zerotierone
      linuxKernel.packages.linux_6_6.perf
      swaybg
      rofi-wayland
    ];

    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT = "1";
      XDG_SESSION_TYPE = "wayland";
      EDITOR = "hx";
    };

    file.".npmrc".text = lib.generators.toINIWithGlobalSection { } {
      globalSection = { prefix = "$HOME/.npm-packages"; };
    };
  } // musicLib.handleFileList [{
    name = "cat.jpg";
    link =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4d/Cat_November_2010-1a.jpg/800px-Cat_November_2010-1a.jpg";
    hash = "0r3jwna7jxw2wafpsgqvbk7ka7qkmp6dx6ndql70pbd20k688qsw";
  }];

  programs.home-manager.enable = true;

  # XDG Portal
  xdg = {
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal ];
      config = { common.default = "*"; };
    };
  };

  # Fish configuration
}

