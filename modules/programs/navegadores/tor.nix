{ pkgs, lib, config, ... }:
{
  options.navegadores.tor = {
    enable = lib.mkEnableOption "Activa Tor y Tor Browser";
  };

  config = lib.mkIf (config.navegadores.tor.enable) {
    userPackages.navegadores = [
      pkgs.tor
      pkgs.tor-browser
    ];

    myImpermanence.users.${config.usuarioPrincipal}.directories = [
      ".local/share/tor-browser"
    ];
  };
}
