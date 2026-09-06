{ pkgs, lib, config, ... }:
{
  options.cf-ddns.enable = lib.mkEnableOption "Activa el script para actualizar la IP en Cloudflare";

  config = lib.mkIf config.cf-ddns.enable {
    sops.secrets = {
      "cloudflare_ddns/ZONE_ID" = {};
      "cloudflare_ddns/CF_TOKEN" = {};
      "cloudflare_ddns/RECORD_ID" = {};
    };

    systemd.timers.cf-ddns = {
      wantedBy = [ "timers.target" ];
      timerConfig.OnCalendar = "*:0/5";
    };

    systemd.services.cf-ddns = {
      script = ''
        IP=$(${pkgs.curl}/bin/curl -s https://api.ipify.org)
        ZONE_ID=$(cat ${config.sops.secrets."cloudflare_ddns/ZONE_ID".path})
        CF_TOKEN=$(cat ${config.sops.secrets."cloudflare_ddns/CF_TOKEN".path})
        RECORD_ID=$(cat ${config.sops.secrets."cloudflare_ddns/RECORD_ID".path})
        ${pkgs.curl}/bin/curl -s -X PUT \
          "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
          -H "Authorization: Bearer $CF_TOKEN" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"mail\",\"content\":\"$IP\",\"proxied\":false}"
      '';
    };
  };
}
