{ lib, config, open-design, ... }:
let
  user = config.vars.usuarioPrincipal;
in
{
  imports = [ open-design.nixosModules.default ];

  options.opendesign = {
    enable = lib.mkEnableOption "Open Design daemon (MCP server para OpenCode)";
    port   = lib.mkOption {
      type    = lib.types.port;
      default = 7457;
      description = "Puerto del daemon Open Design";
    };
  };

  config = lib.mkIf config.opendesign.enable {
    assertions = [{
      assertion = config.mi_sops.enable;
      message = "opendesign requiere sops para OD_API_TOKEN";
    }];

    services.open-design = {
      enable    = true;
      autoStart = true;
      port      = config.opendesign.port;
      environmentFile = config.sops.secrets."opendesign/env".path;
    };

    systemd.services.open-design.environment.PATH = lib.mkForce
      "/run/wrappers/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin";

    sops.secrets."opendesign/env" = {};

    myImpermanence.users.${user}.directories = [ ".open-design" ];
  };
}
