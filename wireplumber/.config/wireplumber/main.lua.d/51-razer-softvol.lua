services.pipewire = {
  enable = true;
  pulse.enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;

  wireplumber = {
    enable = true;
    extraConfig = {
      "51-razer-softvol" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "device.name" = "alsa_card.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01";
              }
            ];
            actions = {
              update-props = {
                "api.alsa.soft-mixer" = true;
                "api.alsa.ignore-db" = true;
              };
            };
          }
          {
            matches = [
              {
                "node.name" = "alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.analog-stereo";
              }
            ];
            actions = {
              update-props = {
                "api.alsa.soft-mixer" = true;
              };
            };
          }
        ];
      };
    };
  };
};
