{ pkgs, lib, config, ... }:
let
  user = config.vars.usuarioPrincipal;
in
{
  options.qutebrowser = {
    enable = lib.mkEnableOption "Activa Qutebrowser";
    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Establece Qutebrowser como navegador predeterminado en XDG MIME";
    };
  };

  config = lib.mkIf config.qutebrowser.enable {
    userPackages.navegadores = [ pkgs.qutebrowser ];

    environment.etc."xdg/qutebrowser/config.py".text = ''
      config.load_autoconfig(False)
      c.colors.webpage.preferred_color_scheme = 'dark'
      c.colors.webpage.darkmode.enabled = True

      # Atajos para integración con Bitwarden CLI (rbw)
      config.bind(',p', 'spawn --userscript qute-rbw')
      config.bind(',P', 'spawn --userscript qute-rbw --password-only')
      config.bind(',u', 'spawn --userscript qute-rbw --username-only')
    '';

    xdg.mime = lib.mkIf config.qutebrowser.default {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http"  = "qutebrowser.desktop";
        "x-scheme-handler/https" = "qutebrowser.desktop";
      };
    };

    myImpermanence.users.${user}.directories = [
      ".config/qutebrowser"
      ".cache/qutebrowser"
      ".local/share/qutebrowser"
    ];
  };
}
