{ ... }:

{
  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/matt/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "/home/matt/.local/bin/url-router.sh";
    DEFAULT_BROWSER = "/home/matt/.local/bin/url-router.sh";
    NB_BROWSER = "firefox";
  };

  programs.nushell = {
    enable = true;
    environmentVariables = {
      EDITOR = "\"nvim\"";
      VISUAL = "\"nvim\"";
      BROWSER = "\"/home/matt/.local/bin/url-router.sh\"";
      DEFAULT_BROWSER = "\"/home/matt/.local/bin/url-router.sh\"";
      NB_BROWSER = "firefox";
    };
  };

  home.shellAliases = {
    term-obs = "kitty -c ~/.config/kitty/obs.conf";
    chrome = "chromium";
  };
}
