{ pkgs, ... }:

let
  soundbarSink = "alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.iec958-stereo";
in
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
            { "node.name" = soundbarSink; }
          ];
          actions.update-props = {
            "priority.session" = 10000;
          };
        }
      ];
    };
  };

  # 99-local.rules sorts before 99-systemd.rules, which tags controlC* for systemd.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{idVendor}=="1532", ATTRS{idProduct}=="054a", ENV{SYSTEMD_USER_WANTS}+="soundbar-detect.service"
  '';

  systemd.user.services.soundbar-detect = {
    description = "Make sure PipeWire lists the Leviathan soundbar when it powers on";
    after = [ "wireplumber.service" ];
    path = [
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.pulseaudio
      pkgs.systemd
    ];
    serviceConfig.Type = "oneshot";
    script = ''
      sink=${soundbarSink}

      wait_for_sink() {
        for _ in $(seq "$1"); do
          pactl list short sinks | grep -qF "$sink" && return 0
          sleep 1
        done
        return 1
      }

      # PipeWire can miss a hotplugged card; WirePlumber re-reads them all on start.
      wait_for_sink 5 || {
        systemctl --user restart wireplumber
        wait_for_sink 10
      }
    '';
  };
}
