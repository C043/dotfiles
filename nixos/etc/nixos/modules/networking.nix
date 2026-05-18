{ ... }:

{
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  services.tailscale.enable = true;
  services.openssh.enable = true;
}
