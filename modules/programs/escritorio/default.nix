{ config, lib, pkgs, ... }:
let
  screenshot = pkgs.writeShellApplication {
    name = "screenshot-wayland";
    runtimeInputs = [ pkgs.grim pkgs.slurp ];
    text = builtins.readFile (pkgs.replaceVars ../../scripts/screenshot-wayland.sh {
      carpeta_pantallazo = "${config.vars.home}/Multimedia/Imagenes/Pantallazos";
    });
  };
  toggle-record = pkgs.writeShellApplication {
    name = "toggle-record-wayland";
    runtimeInputs = [ pkgs.wf-recorder pkgs.slurp ];
    text = builtins.readFile (pkgs.replaceVars ../../scripts/toggle-record-wayland.sh {
      carpeta_grabaciones = "${config.vars.home}/Multimedia/Videos/Grabaciones";
    });
  };
in
{
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

      userPackages.escritorio = [
        pkgs.wl-clipboard pkgs.brightnessctl
        screenshot toggle-record
      ];
    }
    (lib.mkIf config.escritorio.niri {
      programs.niri.enable = true;
      myImpermanence.users.${config.vars.usuarioPrincipal} = {
        directories = [
          ".config/niri" ".cache/niri"
        ];
      };
    })
    (lib.mkIf config.escritorio.mango {
      programs.mango.enable = true;
      myImpermanence.users.${config.vars.usuarioPrincipal} = {
        directories = [
          ".config/mango" ".cache/mango"
        ];
      };
    })
    (lib.mkIf config.escritorio.noctalia {
      programs.noctalia.enable = true;
      myImpermanence.users.${config.vars.usuarioPrincipal} = {
        directories = [
          ".config/noctalia" ".cache/noctalia" ".local/share/noctalia" ".local/state/noctalia"
        ];
      };
    })
  ]);
}
