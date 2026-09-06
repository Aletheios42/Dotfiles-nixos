{ pkgs, lib, config, ... }:
{
  options.navegadores.qutebrowser = {
    enable = lib.mkEnableOption "Activa Qutebrowser";
    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Establece Qutebrowser como navegador predeterminado en XDG MIME";
    };
  };

  config = lib.mkIf config.navegadores.qutebrowser.enable {
    userPackages.navegadores = [ pkgs.qutebrowser ];

    environment.etc."xdg/qutebrowser/config.py".text = ''
      config.load_autoconfig(False)
      c.colors.webpage.preferred_color_scheme = 'dark'
      c.colors.webpage.darkmode.enabled = True
      c.downloads.location.directory = '/home/aletheios42/Descargas'
      c.downloads.location.suggestion = 'never'

      # Ranger como explorador de archivos
      c.fileselect.handler = 'external'
      c.fileselect.single_file.command = ['alacritty', '-e', 'ranger', '--choosefile={}']
      c.fileselect.multiple_files.command = ['alacritty', '-e', 'ranger', '--choosefiles={}']
      c.fileselect.folder.command = ['alacritty', '-e', 'ranger', '--choosedir={}']

      # Atajos para integración con Vaultwarden CLI (rbw)
      config.bind(',p', 'spawn --userscript qute-rbw')
      config.bind(',P', 'spawn --userscript qute-rbw --password-only')
      config.bind(',u', 'spawn --userscript qute-rbw --username-only')
    '';

    xdg.mime = lib.mkIf config.navegadores.qutebrowser.default {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http"  = "qutebrowser.desktop";
        "x-scheme-handler/https" = "qutebrowser.desktop";
      };
    };

    myImpermanence.users.${config.usuarioPrincipal}.directories = [
      ".config/qutebrowser"
      ".cache/qutebrowser"
      ".local/share/qutebrowser"
    ];
  };
}
