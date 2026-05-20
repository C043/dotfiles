{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hypridle
    hyprlock
    hyprpaper
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
    waypaper


    # Settings (modular replacements for gnome-control-center)
    nwg-look
    nwg-displays
    pavucontrol
    networkmanagerapplet
    blueman
  ];
}
