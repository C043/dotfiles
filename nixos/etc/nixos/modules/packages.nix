{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # kitty from nixos-unstable (stable channel lags several minor versions)
  nixpkgs.overlays = [
    (final: prev: {
      kitty =
        (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
          inherit (prev) system;
          config.allowUnfree = true;
        }).kitty;
    })
  ];
  programs.nix-ld.enable = true;
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    # CLI
    stow
    zsh
    fzf
    ripgrep
    wget
    curl
    unzip
    vim
    neovim
    tmux
    pciutils
    libva-utils
    pulseaudio
    v4l-utils
    htop
    lsof
    jq
    yazi
    unar
    psmisc

    # Git
    git
    gitflow
    gh
    tea

    # Dev
    nodejs_22
    pnpm
    python3
    python3Packages.pip
    go
    gcc
    platformio
    nixfmt-rfc-style

    # Apps
    kitty
    obsidian
    (vivaldi.override {
      commandLineArgs = "--disable-gpu-compositing";
    })
    google-chrome
    chromium
    discord
    beeper
    spotify
    zathura
    telegram-desktop
    scribus

    # Fonts
    jetbrains-mono
    nerd-fonts.jetbrains-mono

    # Keyboard
    vial
    via
  ];
}
