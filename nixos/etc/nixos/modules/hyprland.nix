{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    hyprlock
    hyprpaper
    waybar
    wofi
    mako
    grim
    slurp
    hyprshot
    wl-clipboard
    swayosd
    playerctl
    nixos-artwork.wallpapers.nineish-dark-gray
  ];
}
