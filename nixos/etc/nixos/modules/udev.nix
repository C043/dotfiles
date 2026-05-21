{ ... }:

{
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", TAG+="uaccess"
  '';

  users.groups.plugdev = { };
}
