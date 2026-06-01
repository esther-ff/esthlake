{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.fira-code
    nerd-fonts.monaspace
  ];

}
