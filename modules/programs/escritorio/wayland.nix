{ pkgs, lib, config, ... }:
let
  home = config.users.users.${config.usuarioPrincipal}.home;
in
  {
  options.escritorio.enable = lib.mkEnableOption "activa el escritorio";

  config = lib.mkIf (config.escritorio.enable) {

    xdg = {
      # icons.enable = true;
      # menus.enable = true;
      # mime.enable = true;
      # autostart.enable = true;
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    };
    services.gnome.gcr-ssh-agent.enable = false;

    userPackages.escritorio = [
      pkgs.wl-clipboard 
      pkgs.brightnessctl 
      pkgs.kooha 
      pkgs.rofi-screenshot
      pkgs.grim   # <--- Recomendado si usas Wayland
      pkgs.slurp  # <--- Recomendado si usas Wayland

      (pkgs.rofi.override {
        plugins = [
          pkgs.rofi-emoji
        ];
      })
    ];
    # system.activationScripts.userDirs = {
    #   deps = [ "users" ];
    #   text = ''
    # mkdir -p ${home}/Escritorio ${home}/Descargas \
    #     ${home}/Documentos/Plantillas \
    #     ${home}/Multimedia/{Música,Imágenes,Vídeos} \
    #     ${home}/Público
    #     cat > ${home}/.config/user-dirs.dirs <<EOF
    #     XDG_DESKTOP_DIR="$HOME/Escritorio"
    #     XDG_DOWNLOAD_DIR="$HOME/Descargas"
    #     XDG_DOCUMENTS_DIR="$HOME/Documentos"
    #     XDG_MUSIC_DIR="$HOME/Multimedia/Música"
    #     XDG_PICTURES_DIR="$HOME/Multimedia/Imágenes"
    #     XDG_VIDEOS_DIR="$HOME/Multimedia/Vídeos"
    #     XDG_TEMPLATES_DIR="$HOME/Documentos/Plantillas"
    #     XDG_PUBLICSHARE_DIR="$HOME/Público"
    #     -EOF
    #     chown -R ${config.usuarioPrincipal}:users ${home}/.config/user-dirs.dirs \
    #     ${home}/Escritorio ${home}/Descargas \
    #     ${home}/Documentos ${home}/Multimedia ${home}/Público
    #   '';
    # };
    myImpermanence.users.${config.usuarioPrincipal} = {
      files = [ ".config/user-dirs.dirs" ];
      directories = [
        "Escritorio" "Descargas" "Documentos" "Multimedia" "Público"
      ];
    };
  };
}
