{ pkgs, ... }:

let
  hints = pkgs.python3Packages.buildPythonApplication rec {
    pname = "hints";
    version = "unstable";
    format = "setuptools";

    src = pkgs.fetchFromGitHub {
      owner = "AlfredoSequeida";
      repo = "hints";
      rev = "3b60027b1e4cf153ff2380c65ef47fae337c4e9d";
      hash = "sha256-JUtYl6DbiTX2cLhfeRT+25unJFMDuwtMiBAdcDyfpPU=";
    };

    nativeBuildInputs = with pkgs; [
      gobject-introspection
      wrapGAppsHook4
      pkg-config
    ];

    buildInputs = with pkgs; [
      gtk3
      gtk4
      gtk-layer-shell
      gtk4-layer-shell
      cairo
      glib
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      pygobject3
      pillow
      pyscreenshot
      opencv4
      evdev
      dbus-python
      rich
    ];

    postPatch = ''
      substituteInPlace setup.py \
        --replace-fail "self.install_hintsd_service()" "pass"
    '';

    env.HINTS_EXPECTED_BIN_DIR = "bin";

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix GI_TYPELIB_PATH : "${pkgs.gtk3}/lib/girepository-1.0"
        --prefix GI_TYPELIB_PATH : "${pkgs.gtk4}/lib/girepository-1.0"
        --prefix GI_TYPELIB_PATH : "${pkgs.gtk-layer-shell}/lib/girepository-1.0"
        --prefix GI_TYPELIB_PATH : "${pkgs.gtk4-layer-shell}/lib/girepository-1.0"
        --prefix PATH : "${pkgs.lib.makeBinPath [ pkgs.grim ]}"
      )
    '';

    doCheck = false;

    meta = with pkgs.lib; {
      description = "Vimium-like hints for the Linux desktop";
      homepage = "https://github.com/AlfredoSequeida/hints";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
    };
  };
in
{
  environment.systemPackages = [ hints ];
}
