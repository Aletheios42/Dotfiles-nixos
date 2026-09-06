{ lib, config, ...}:
{
  options.documentacion.enable = lib.mkEnableOption "Este bloque activo man e info";

  config = lib.mkIf (config.documentacion.enable) {
    documentation = {
      enable = true;
      dev.enable = true;
      info.enable = true;
      man.enable = true;
      nixos.enable = true;          # nixos-help y opciones locales
    };
  };
}
