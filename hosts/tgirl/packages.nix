{ pkgs, ... }:
with pkgs;
{
  environment.systemPackages = [
    fzf
    btop
    element-desktop
    file
    dunst
    bottles
    swaylock
    just
    python3
    virt-manager
    man-pages
    thunderbird
    signal-desktop
    libreoffice
    openjdk
    prismlauncher
    wireshark
    cargo-mommy
    obsidian
    git
    pipewire
    ntfs3g
    pavucontrol
    kdePackages.okular
    ironbar
    zen-browser
    imv
    yazi
  ];
}
