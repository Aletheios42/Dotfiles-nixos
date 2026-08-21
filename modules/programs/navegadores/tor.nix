{ pkgs, lib, config, ... }:
let
  user = config.vars.usuarioPrincipal;
in
{
  options.tor = {
    enable = lib.mkEnableOption "Activa Tor y Tor Browser";
  };

  config = lib.mkIf config.tor.enable {
    userPackages.navegadores = [
      pkgs.tor
      pkgs.tor-browser
    ];

    myImpermanence.users.${user}.directories = [
      ".local/share/tor-browser"
    ];
  };
}
