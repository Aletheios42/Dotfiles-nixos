{ pkgs, lib, config, ... }:
{
  options.lectura = {
    calibre = lib.mkEnableOption "Activa calibre";
    zathura = lib.mkEnableOption "Activa zathura";
    koreader = lib.mkEnableOption "Activa koreader";
  };

  config = lib.mkMerge [
    (lib.mkIf config.lectura.zathura { userPackages.lectura = [ pkgs.zathura ]; })
    (lib.mkIf config.lectura.koreader { userPackages.lectura = [ pkgs.koreader ]; })
    (lib.mkIf config.lectura.calibre { userPackages.lectura = [ pkgs.calibre ]; })
  ];
}
