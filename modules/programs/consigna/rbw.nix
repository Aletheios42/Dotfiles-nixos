{ pkgs, lib, config, ... }:
{
  options.rbw = {
    enable = lib.mkEnableOption "Activa cliente Bitwarden CLI (rbw)";
    pinentry = lib.mkOption {
      type = lib.types.package;
      default = pkgs.pinentry-curses;
      description = "Paquete pinentry (curses, rofi, gnome, etc.)";
    };
  };

  config = lib.mkIf config.rbw.enable {
    userPackages.seguridad = [
      pkgs.rbw
      config.rbw.pinentry
      pkgs.rofi-rbw-wayland
    ];

    myImpermanence.users.${config.usuarioPrincipal}.directories = [
      ".config/rbw"
      ".cache/rbw"
    ];
  };
}
