{ pkgs, ... }:

let
  # Salamander Grand Piano V3 (Yamaha C5), CC-BY-3.0, by Alexander Holm.
  salamander = pkgs.fetchFromGitHub {
    name = "salamander-grand-piano";
    owner = "sfzinstruments";
    repo = "SalamanderGrandPiano";
    rev = "3382bf9496bba2486f5ab0de55a264d1dfc38404";
    hash = "sha256-PpTh8QPHgtU6JGYKZkbBrIhlQMg+ykJBGlOzge9Qfl8=";
  };

  # The samples are recorded with real headroom (C4 at velocity 64 peaks around
  # -26 dBFS) and sfizz_jack has no gain flag, so boost it in the SFZ. Every <global>
  # needs it, since each one resets the last. Less velocity tracking lifts soft notes
  # more than loud ones; plain gain would clip on chords first.
  salamanderLoud = pkgs.runCommand "salamander-grand-piano-loud" { } ''
    mkdir $out
    ln -s ${salamander}/Data ${salamander}/Samples $out/
    sed -e 's/^<global>/<global>\nglobal_volume=8/' \
      -e 's/^set_hdcc$VELTRACK=0.73/set_hdcc$VELTRACK=0.3/' \
      "${salamander}/Salamander Grand Piano V3.sfz" > "$out/Salamander Grand Piano V3.sfz"
  '';

  # pw-jack runs sfizz on PipeWire's JACK libs, so services.pipewire.jack stays off.
  piano = pkgs.writeShellScriptBin "piano" ''
    pw_link=${pkgs.pipewire}/bin/pw-link

    connect_keyboard() {
      keyboard=$("$pw_link" -o | grep -m1 'Keystation.*(USB MIDI)')
      if [ -n "$keyboard" ]; then
        "$pw_link" "$keyboard" piano:input
        echo "piano: ready"
      else
        echo "piano: Keystation not found, connect it and restart" >&2
      fi
    }

    # sfizz only exits once stdin closes, so Ctrl+C has to kill its stdin as well.
    ${pkgs.coreutils}/bin/sleep infinity |
      ${pkgs.coreutils}/bin/stdbuf -oL ${pkgs.pipewire.jack}/bin/pw-jack ${pkgs.sfizz}/bin/sfizz_jack \
      --client_name piano \
      --jack_autoconnect=true \
      --num_voices 128 \
      "${salamanderLoud}/Salamander Grand Piano V3.sfz" 2>&1 |
      while IFS= read -r line; do
        case "$line" in
          # A note arriving mid-load trips an assert in sfizz, so link only after it.
          "Instrument loaded:"*) connect_keyboard ;;
          # Printed for every note when the loader threads can't get realtime priority.
          *"Cannot set current thread scheduling"*) ;;
          *) printf '%s\n' "$line" ;;
        esac
      done
  '';
in
{
  environment.systemPackages = [ piano ];
}
