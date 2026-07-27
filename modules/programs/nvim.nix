{ pkgs, lib, config, ... }:
let
  user  = config.vars.usuarioPrincipal;
in
{
  options.editor.enable = lib.mkEnableOption "Activa nvim";

  config = lib.mkIf config.editor.enable {

    environment.systemPackages = [ pkgs.chafa pkgs.jq ];

    programs.nvf = {
      enable = true;
      settings = import ./nvim-config.nix {
        inherit pkgs;
        host   = config.ai.llama.fim.host;
        port   = config.ai.llama.fim.port;
        model  = config.ai.llama.fim.model;
      };
    };

    myImpermanence.users.${user}.directories = [
      ".config/nvim"
      ".local/share/nvim"
      ".local/state/nvim"
      ".cache/nvim"
    ];
  };
}
