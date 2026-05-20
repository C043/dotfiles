{ lib, ... }:

{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.profiles.gdm.databases = [{
    settings."org/gnome/desktop/session".idle-delay = lib.gvariant.mkUint32 0;
    settings."org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-type = "nothing";
      idle-dim = false;
    };
  }];
}
