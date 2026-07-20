{ lib, config, ... }:
{
  options.ddns = {
    enable = lib.mkEnableOption "Activa DDNS con inadyn para Cloudflare";
    dominio = lib.mkOption {
      type = lib.types.str;
      default = config.vars.dominio;
      description = "Dominio base para DDNS";
    };
    hostnames = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "@" ];
      description = "Lista de hostnames a actualizar (sin el dominio base)";
    };
  };

  config = lib.mkIf config.ddns.enable {
    assertions = [
      {
        assertion = config.mi_sops.enable;
        message = "ddns requiere sops (mi_sops.enable)";
      }
      {
        assertion = config.ddns.dominio != "";
        message = "ddns.dominio no puede estar vacío";
      }
      {
        assertion = config.ddns.hostnames != [];
        message = "ddns.hostnames debe tener al menos un hostname";
      }
    ];

    sops.secrets."cloudflare/api_token" = {};

    sops.templates."inadyn-conf" = {
      owner = "inadyn";
      group = "inadyn";
      content = let
        dominio = config.ddns.dominio;
        hosts = map (h: if h == "@" then dominio else "${h}.${dominio}") config.ddns.hostnames;
        hostnameList = "{ ${lib.concatStringsSep ", " (map (h: ''"${h}"'') hosts)} }";
      in ''
        provider cloudflare {
            username = "${dominio}"
            password = "${config.sops.placeholder."cloudflare/api_token"}"
            hostname = ${hostnameList}
        }
      '';
    };

    services.inadyn = {
      enable = true;
      configFile = config.sops.templates."inadyn-conf".path;
    };

    systemd.services.inadyn = {
      after = [ "sops-nix.service" ];
      wants = [ "sops-nix.service" ];
    };

    myImpermanence.system.directories = [ "/var/lib/inadyn" ];
  };
}
