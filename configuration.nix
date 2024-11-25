# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { 
    config = config.nixpkgs.config;
    overlays = config.nixpkgs.overlays;
  };
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

  # Enable networking
  networking.networkmanager.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
    daemon.settings = {
      userland-proxy = false;
    };
  };

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.matt = {
    isNormalUser = true;
    description = "Matt White";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
    shell = unstable.nushell;
  };

  nix.settings.allowed-users = [ "matt" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    kdiff3
    dig
    ranger
    tmux
    fzf
    grc
    packagekit
    cifs-utils
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
    networkmanagerapplet
    pavucontrol
    pipewire
    chezmoi
    age
    gh
    dconf
    lshw
    pciutils
    vim
    wofi
    gnome.gnome-remote-desktop
    gnome.gnome-session
    waybar

    # Unstable packages
    unstable.nwg-displays
    unstable.hyprpaper
    unstable.hyprgui
    unstable.neovim
    unstable.nushell
  ];

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    
    # Optional, may help with some apps
    __GL_GSYNC_ALLOWED = "0";
    __GL_VRR_ALLOWED = "0";
    WLR_DRM_NO_ATOMIC = "1";
  };
  xdg.portal = {
    enable = true;
    config.common.default = [ "hyprland" ];
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.light.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = unstable.hyprland.override {
      debug = true;
    };
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
    openFirewall = true;
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
  services.udisks2 = {
    enable = true;
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

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.packagekit.enable = true;
  services.xrdp = {
    enable = true;
    openFirewall = true; 
    defaultWindowManager = "${pkgs.gnome3.gnome-session}/bin/gnome-session";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.ledger-udev-rules
  ];
  services.pcscd.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  services.greetd = {                                                      
    enable = true;                                                         
    settings = {                                                           
      default_session = {                                                  
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "greeter";                                                  
      };                                                                   
    };                                                                     
  };


  security.rtkit.enable = true;
  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  networking.firewall = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
