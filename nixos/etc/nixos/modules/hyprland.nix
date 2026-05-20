{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hypridle
    hyprlock

    waybar
    wofi
    swaynotificationcenter
    grim
    slurp
    hyprshot
    imv
    libreoffice
    wl-clipboard
    swayosd
    playerctl
    hyprpaper
    nixos-artwork.wallpapers.binary-black

    # Settings (modular replacements for gnome-control-center)
    nwg-look
    nwg-displays
    pavucontrol
    networkmanagerapplet
    blueman
  ];
}
