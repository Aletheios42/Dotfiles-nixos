{ pkgs, lib, config, ... }:
{
  options.shell.direnv = lib.mkOption { type = lib.types.bool; default = true; description = "activa direnv con nix-direnv"; };

  config = lib.mkIf config.shell.direnv {
    userPackages.direnv = [ pkgs.direnv pkgs.nix-direnv ];
    myImpermanence.users.${config.vars.usuarioPrincipal}.directories = [ ".config/direnv" ];
  };
}
