#!/usr/bin/env sh

export HOSTNAME="${HOSTNAME:-desk}"
# TODO setup files that can be dynamically detected and added.
export CUSTOM_SYSTEM_CONFIG="
  boot.kernel.sysctl.\"net.ipv4.ip_forward\" = 1;
  services.printing = {
    enable = true;
    package = pkgs.unstable.cups;
    drivers = [
      pkgs.stable.cups-brother-hll2350dw
      pkgs.custom.ptouch-driver
    ];
  };
  services.avahi = {
    publish = {
      enable = true;
      userServices = true;
    };
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      stable.nvidia-vaapi-driver
    ];
    package = pkgs.stable.mesa.drivers;
  };
  services.xserver.videoDrivers = [\"nvidia\"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party \"nouveau\" open source driver).
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
"
