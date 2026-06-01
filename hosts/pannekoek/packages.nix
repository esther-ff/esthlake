{ pkgs, ... }:
with pkgs;
{
  environment.systemPackages = [
    fzf
    btop
    file
    just
    python3
    man-pages
    wireshark
    cargo-mommy
    git
    ntfs3g
    yazi
  ];
}
