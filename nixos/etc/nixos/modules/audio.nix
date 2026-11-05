{ ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Keep the MIDI-only Keystation off the shared card numbers. PipeWire 1.4.9 never
  # forgets a card without PCM devices, so a later card reusing its number is ignored.
  boot.extraModprobeConfig = ''
    options snd-usb-audio index=9 vid=0x0763 pid=0x3109
  '';

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
