{ pkgs, lib, config, ... }:

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
  swayConfigText = import ./sway-config.nix { inherit pkgs; };
in
{
  config = lib.mkIf (config.escritorio.enable && config.escritorio.sway) {
    programs.sway.enable = true;
    programs.waybar.enable = true;
    programs.sway.extraPackages = [
      pkgs.rofi pkgs.wofi pkgs.swaylock pkgs.wl-clipboard pkgs.brightnessctl
      screenshot toggle-record
    ];
    environment.etc."sway/config".text = swayConfigText;
  };
}
