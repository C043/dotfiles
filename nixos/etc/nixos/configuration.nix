{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/locale.nix
    ./modules/nvidia.nix
    ./modules/gnome.nix
    ./modules/hyprland.nix
    ./modules/audio.nix
    ./modules/networking.nix
    ./modules/user.nix
    ./modules/packages.nix
    ./modules/docker.nix
    ./modules/udev.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.11";
}
