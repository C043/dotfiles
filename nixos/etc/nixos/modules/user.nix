{ pkgs, ... }:

{
  users.users.c043 = {
    isNormalUser = true;
    description = "Mario Fragnito";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "udev"
    ];
  };

  fileSystems."/run/media/c043/Drive" = {
    device = "/dev/disk/by-uuid/E0D40A63D40A3C72";
    fsType = "ntfs";
    options = [
      "defaults"
      "nofail"
    ];
  };
}
