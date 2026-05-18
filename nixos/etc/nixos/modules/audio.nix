{ ... }:

{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

    extraConfig.pipewire-pulse."51-razer-softvol" = {
      "pulse.cmd" = [
        {
          cmd = "load-module";
          args = "module-null-sink sink_name=razer_soft sink_properties=device.description=Razer_Software_Volume";
          flags = [ "nofail" ];
        }
        {
          cmd = "load-module";
          args = "module-loopback source=razer_soft.monitor sink=alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.analog-stereo latency_msec=20";
          flags = [ "nofail" ];
        }
        {
          cmd = "set-default-sink";
          args = "razer_soft";
          flags = [ "nofail" ];
        }
      ];
    };
  };
}
