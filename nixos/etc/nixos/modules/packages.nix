{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
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
    pulseaudio
    htop
    lsof
    jq

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
    vivaldi
    google-chrome
    chromium
    discord
    spotify
    zathura

    # Fonts
    jetbrains-mono
    nerd-fonts.jetbrains-mono

    # Keyboard
    vial
    via
  ];
}
