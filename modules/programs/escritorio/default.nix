{ config, lib, pkgs, ... }:

{
  imports = [ ./sway.nix ];

  options.escritorio = {
    enable = lib.mkEnableOption "activar escritorio Wayland";
    sway = lib.mkEnableOption "Activa sway";
    niri = lib.mkEnableOption "Activa niri";
    mango = lib.mkEnableOption "Activa mango";
    noctalia = lib.mkEnableOption "Activa noctalia (shell/bar)";
  };

  config = lib.mkIf config.escritorio.enable (lib.mkMerge [
    {
      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    }
    (lib.mkIf config.escritorio.niri {
      programs.niri.enable = true;
    })
    (lib.mkIf config.escritorio.mango {
      programs.mango.enable = true;
    })
    (lib.mkIf config.escritorio.noctalia {
      programs.noctalia.enable = true;
    })
    {
      myImpermanence.users.${config.vars.usuarioPrincipal} = {
        directories = [
          ".config/sway" ".config/waybar" ".cache/sway"
          ".config/mango" ".cache/mango"
          ".config/noctalia" ".cache/noctalia" ".local/share/noctalia"
        ];
      };
    }
  ]);
}
