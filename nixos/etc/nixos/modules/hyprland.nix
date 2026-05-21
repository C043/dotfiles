{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        "org.freedesktop.impl.portal.GlobalShortcuts" = "hyprland";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };

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
