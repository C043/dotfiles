# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # NVIDIA drivers.
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;

    # Required to choose explicitly on modern NVIDIA drivers.
    # For RTX 50-series / recent GPUs, start with the open kernel module.
    open = true;

    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.autoSuspend = false;
  services.desktopManager.gnome.enable = true;

  # Keep GNOME as the default shell, but install Hyprland as an alternate session.
  programs.hyprland.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "it";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "it2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.c043 = {
    isNormalUser = true;
    description = "Mario Fragnito";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "udev"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  fileSystems."/run/media/c043/Drive" = {
    device = "/dev/disk/by-uuid/E0D40A63D40A3C72";
    fsType = "ntfs";
    options = [
      "defaults"
      "nofail"
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gnomeExtensions.blur-my-shell
    gnomeExtensions.pop-shell
    gnomeExtensions.unblank
    gnome-extension-manager
    gnome-tweaks
    stow
    zsh
    pciutils
    git
    gitflow
    gh
    tea
    tailscale
    tmux
    docker-compose
    obsidian
    wget
    curl
    vial
    via
    vim
    kitty
    hyprlock
    hyprpaper
    nixos-artwork.wallpapers.nineish-dark-gray
    waybar
    wofi
    mako
    grim
    slurp
    wl-clipboard
    nixfmt-rfc-style
    fzf
    nodejs_22
    pnpm
    neovim
    python3
    python3Packages.pip
    vivaldi
    google-chrome
    chromium
    discord
    unzip
    platformio
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    go
    gcc
    ripgrep
    zathura
    spotify
    pulseaudio
    playerctl
    swayosd
    wl-clipboard
  ];
  programs.zsh.enable = true;
  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

  services.udev.extraRules = ''
    # VIA / Vial keyboards via hidraw
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
  '';

  users.groups.plugdev = { };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
