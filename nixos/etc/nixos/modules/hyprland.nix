{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hypridle
    hyprlock
    hyprpaper
    waybar
    wofi
    mako
    grim
    slurp
    hyprshot
    imv
    libreoffice
    wl-clipboard
    swayosd
    playerctl
    nixos-artwork.wallpapers.nineish-dark-gray
  ];
}
