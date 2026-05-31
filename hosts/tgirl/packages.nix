{ pkgs, ... }:
with pkgs;
{
  environment.systemPackages = [
    fzf
    btop
    element-desktop
    file
    dunst
    swaylock
    just
    python3
    virt-manager
    man-pages
    thunderbird
    signal-desktop
    libreoffice-fresh
    openjdk
    prismlauncher
    wireshark
    cargo-mommy
    obsidian
    git
    ntfs3g
    kdePackages.okular
    ironbar
    zen-browser
    imv
    yazi
  ];
}
