# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # TODO make this portable/reproducible
  i3exit = import /home/matt/.config/nixpkgs/pkgs/i3exit { inherit pkgs; };
  blurlock = import /home/matt/.config/nixpkgs/pkgs/blurlock { inherit pkgs; };
  upkg = import <nixos-unstable> { inherit pkgs; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./luks-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fake-hostname"; # Define your hostname.
 # networking.wireless = {
 #   enable = true;
 #   userControlled.enable = true;
 # };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    desktopManager.gnome.enable = false;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.gnome.gnome-remote-desktop.enable = true;

  services.displayManager = {
    defaultSession = "none+i3";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    description = "Matt White";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.nushell;
  };

  nix.settings.allowed-users = [ "matt" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    gdb
    killall
    python312
    nodejs
    git
    git-lfs
    dig
    ripgrep
    ranger
    tmux
    fzf
    grc
    packagekit
    cifs-utils
    lxappearance
    kitty
    mediainfo
    sqlite
    lightdm
    lightdm-slick-greeter
    nitrogen
    bluez
    blueberry
    udiskie
    polkit
    polkit_gnome
    brightnessctl
    networkmanagerapplet
    pavucontrol
    pipewire
    chezmoi
    age
    gh
    dconf
    lshw
    vim
    gnome.gnome-remote-desktop
    gnome.gnome-session

    # Unstable packages
    upkg.neovim
    upkg.nushell

    # Custom packages
    blurlock
    i3exit
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:
  hardware = {
    enableRedistributableFirmware = true;
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    pulseaudio.enable = false;
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
        UseDns = true;
        StrictModes = false;
        X11Forwarding = false;
        AllowUsers = [ "matt" ];
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
    };
  };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
  };
  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = false;
  };

  services.packagekit.enable = true;
  services.xrdp = {
    enable = true;
    openFirewall = true; 
    defaultWindowManager = "${pkgs.gnome3.gnome-session}/bin/gnome-session";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.flatpak.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common = {
        default = [
          "gtk"
	      ];
      };
    };
  };

  systemd.services = {
    NetworkManager-wait-online.enable = pkgs.lib.mkForce false;

    flatpak-repo = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 3389 22 ];
    allowedUDPPorts = [ 3389 ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
