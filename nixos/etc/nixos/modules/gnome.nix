{ pkgs, ... }:

{
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.autoSuspend = false;
  boot.kernelParams = [ "consoleblank=0" ];
  services.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    gnomeExtensions.blur-my-shell
    gnome-extension-manager
    gnome-tweaks
  ];
}
