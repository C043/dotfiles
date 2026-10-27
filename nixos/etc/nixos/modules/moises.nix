{ pkgs, lib, ... }:

let
  # Drop any Moises AppImage from https://desktop.moises.ai/ in here and rebuild.
  # The newest version found is installed; the file must stay here, it's the source.
  appimageDir = "/home/c043/Applications";

  versionOf =
    name:
    let
      m = builtins.match ".*-([0-9]+(\\.[0-9]+)*).*" name;
    in
    if m == null then "0" else builtins.head m;

  candidates = lib.optionals (builtins.pathExists appimageDir) (
    builtins.filter (name: builtins.match "[Mm]oises.*\\.AppImage" name != null) (
      builtins.attrNames (builtins.readDir appimageDir)
    )
  );

  newest = lib.last (
    lib.sort (a: b: builtins.compareVersions (versionOf a) (versionOf b) < 0) candidates
  );

  available = candidates != [ ];
  version = versionOf newest;

  # Copied into the store at eval time; builtins.path gives it a store-safe name.
  src = builtins.path {
    path = "${appimageDir}/${newest}";
    name = "moises-${version}.AppImage";
  };

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
    No Moises AppImage in ${appimageDir}, skipping it. Download it from
    https://desktop.moises.ai/ and put it there.
  '';
}
