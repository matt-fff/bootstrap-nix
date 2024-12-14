{ pkgs, ... }:

{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "url-router.desktop";
        "x-scheme-handler/http" = "url-router.desktop";
        "x-scheme-handler/https" = "url-router.desktop";
        "x-scheme-handler/ftp" = "url-router.desktop";
        "x-scheme-handler/chrome" = "url-router.desktop";
        "application/xhtml+xml" = "url-router.desktop";
        "application/x-extension-xhtml" = "url-router.desktop";
        "application/x-extension-xht" = "url-router.desktop";
        "application/x-extension-htm" = "url-router.desktop";
        "application/x-extension-html" = "url-router.desktop";
        "application/atom+xml" = "url-router.desktop";
        "application/x-extension-shtml" = "url-router.desktop";
        "application/rss+xml" = "url-router.desktop";

        "application/pdf" = "url-router.desktop";
        "text/calendar" = "morgen.desktop";
        "application/octet-stream" = "vlc.desktop";
        "inode/directory" = "nautilus.desktop";
        "image/jpeg" = "nomacs.desktop";
        "image/png" = "nomacs.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "message/rfc822" = "thunderbird.desktop";
        "application/x-extension-eml" = "thunderbird.desktop";
        "application/x-extension-msg" = "thunderbird.desktop";
      };
    };
    desktopEntries = {
      url-router = {
        name = "DxBrowser";
        genericName = "Browser";
        exec = "/home/matt/.local/bin/url-router.sh";
        icon = "/home/matt/MEGA/Images/icons/globe-solid.svg";
        comment = "Open URLs in the right browser";
        categories = [ "WebBrowser" ];
        type = "Application";
      };
      dx-bluemail = {
        name = "DxBlueMail";
        genericName = "Email Reader";
        exec = "bluemail --disable-gpu-sandbox";
        icon = "bluemail";
        comment = "Free, secure, universal email app, capable of managing an unlimited number of mail accounts";
        categories = [ "Office" ];
        mimeType = [ "x-scheme-handler/me.blueone.linux" "x-scheme-handler/mailto" ];
        type = "Application";
      };
    };
  };
  
  home.pointerCursor = {
    name = "phinger-cursors-dark";
    package = pkgs.phinger-cursors;
    size = 24;
    gtk.enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Gruvbox-Dark";
      package = pkgs.gruvbox-gtk-theme;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
    gtk4.extraConfig = {
      Settings = ''gtk-application-prefer-dark-theme=1'';
    };
  };
}
