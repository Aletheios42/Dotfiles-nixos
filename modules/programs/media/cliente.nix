{ pkgs, lib, config, ... }:
{
  options.media.cliente = lib.mkEnableOption "Activa paquetes multimedia y OBS";

  config = lib.mkIf config.media.cliente {
    userPackages.media = [
      pkgs.cmus
      pkgs.pavucontrol
      pkgs.vlc
      pkgs.mpv
      pkgs.ffmpeg
      pkgs.ardour
      pkgs.blender
      pkgs.grayjay
    ];

    userPackages.obs = [
      (pkgs.wrapOBS {
        plugins = [
          pkgs.obs-studio-plugins.wlrobs
          pkgs.obs-studio-plugins.obs-vkcapture
          pkgs.obs-studio-plugins.input-overlay
        ];
      })
    ];

    myImpermanence.users.${config.vars.usuarioPrincipal}.directories = [
      ".local/share/Grayjay"
    ];
  };
}
