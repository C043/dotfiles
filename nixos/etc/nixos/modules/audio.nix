{ ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

    wireplumber.extraConfig."51-default-sink" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.iec958-stereo"; }
          ];
          actions.update-props = {
            "priority.session" = 10000;
          };
        }
      ];
    };
  };
}
