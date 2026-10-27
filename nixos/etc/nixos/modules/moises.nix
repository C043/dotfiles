{ pkgs, lib, ... }:

let
  version = "2.1.0";

  # No stable public download URL; desktop.moises.ai picks the build by user agent.
  # Download the AppImage manually, then: nix-store --add-fixed sha256 <file>
  src = pkgs.requireFile {
    name = "moises-desktop-${version}x86_64.AppImage";
    url = "https://desktop.moises.ai/";
    hash = "sha256-eHoGyEgPmv63rCCqbMaUPgLxV0DhFL9PizUqZROwH70=";
  };

  # Skip the package instead of failing the whole rebuild on machines where the
  # AppImage hasn't been added yet. Context is discarded so the check doesn't
  # try to realise src (which would fail with requireFile's error).
  available = builtins.pathExists (builtins.unsafeDiscardStringContext src.outPath);

  moises = pkgs.appimageTools.wrapType2 {
    pname = "moises";
    inherit version src;

    extraInstallCommands =
      let
        contents = pkgs.appimageTools.extract {
          pname = "moises";
          inherit version src;
        };
      in
      ''
        install -Dm444 ${contents}/moises-desktop.desktop $out/share/applications/moises.desktop
        substituteInPlace $out/share/applications/moises.desktop \
          --replace-fail "Exec=AppRun --no-sandbox" "Exec=moises"
        cp -r ${contents}/usr/share/icons $out/share/
      '';

    meta = with pkgs.lib; {
      description = "AI-powered music practice app (stem separation, chords, tempo)";
      homepage = "https://moises.ai";
      license = licenses.unfree;
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "moises";
    };
  };
in
{
  environment.systemPackages = lib.optional available moises;

  warnings = lib.optional (!available) ''
    Moises AppImage not in the Nix store, skipping it. Download it from
    https://desktop.moises.ai/ and run:
      nix-store --add-fixed sha256 moises-desktop-${version}x86_64.AppImage
  '';
}
