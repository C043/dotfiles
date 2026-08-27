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
    libva-utils
    pulseaudio
    v4l-utils
    htop
    iotop
    sysstat
    lsof
    jq
    yazi
    unar
    psmisc
    cava
    cmatrix
    borgbackup

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
    tree-sitter

    # Java
    jdk21
    maven
    gradle

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
