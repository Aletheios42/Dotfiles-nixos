{ pkgs, lib, config, ... }:
{
  options.shell.kmscon = lib.mkOption { type = lib.types.bool; default = false; description = "Es emulador de tty moderno.... No Activar; problemas con wayland"; };

  config = lib.mkIf config.shell.kmscon {
    services.kmscon.package = pkgs.kmscon;
    services.kmscon = { enable = true; hwRender = true; useXkbConfig = true; config = { font-name = "DejaVu Sans Mono"; font-size = 12; }; };
  };
}
