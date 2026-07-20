{ lib, config, ... }:
{
  options.mi_mailserver = {
    enable = lib.mkEnableOption "Activa el servidor de correo";
    accounts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          hashedPasswordFile = lib.mkOption { type = lib.types.str; };
          aliases = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
        };
      });
      description = "Cuentas de correo del servidor";
    };
    relay = {
      enable = lib.mkEnableOption "Activa relay SMTP via smarthost (ej. Mailgun)";
      host = lib.mkOption {
        type = lib.types.str;
        default = "smtp.mailgun.org";
        description = "Host del smarthost";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 587;
        description = "Puerto del smarthost";
      };
    };
  };

  config = lib.mkIf config.mi_mailserver.enable {
    assertions = [
      {
        assertion = config.vars.dominio != "";
        message = "El dominio debe estar configurado para usar el mailserver.";
      }
      {
        assertion = config.mi_mailserver.accounts != {};
        message = "Debe haber al menos una cuenta de correo configurada.";
      }
      {
        assertion = config.mi_sops.enable;
        message = "mi_mailserver requiere sops (mi_sops.enable)";
      }
    ];

    sops.secrets."mailserver/admin_pass" = {};
    sops.secrets."mailserver/relay_user" = lib.mkIf config.mi_mailserver.relay.enable {};
    sops.secrets."mailserver/relay_pass" = lib.mkIf config.mi_mailserver.relay.enable {};

    sops.templates."postfix-sasl-passwd" = {
      owner = "postfix";
      group = "postfix";
      mode = "0600";
      content = lib.mkIf config.mi_mailserver.relay.enable ''
        [${config.mi_mailserver.relay.host}]:${toString config.mi_mailserver.relay.port} ${config.sops.placeholder."mailserver/relay_user"}:${config.sops.placeholder."mailserver/relay_pass"}
      '';
    };

    # Configuramos un bloque de Nginx ficticio para forzar a ACME a generar 
    # el certificado del subdominio mail.
    services.nginx.virtualHosts."mail.${config.vars.dominio}" = {
      useACMEHost = "wildcard";
      forceSSL = true;
    };

    # Relay SMTP via smarthost (Postfix directo)
    # Usamos texthash: en lugar de hash: para que Postfix lea el archivo de texto
    # directamente sin necesidad de compilar .db con postmap (que falla sobre
    # symlinks hacia /run/secrets/rendered, que es read-only).
    services.postfix = lib.mkIf config.mi_mailserver.relay.enable {
      settings.main = {
        relayhost = [ "[${config.mi_mailserver.relay.host}]:${toString config.mi_mailserver.relay.port}" ];
        smtp_sasl_password_maps = "texthash:/var/lib/postfix/conf/sasl_passwd";
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "noanonymous";
        smtp_tls_security_level = lib.mkForce "encrypt";
      };
    };

    # Enlazar el template Sasl-passwd de sops hacia /var/lib/postfix/conf/ sin
    # usar mapFiles (que invocaría postmap sobre un target read-only y fallaría).
    # tmpfiles crea el dir /var/lib/postfix/conf si no existe y el symlink.
    systemd.tmpfiles.settings."postfix-sasl" = lib.mkIf config.mi_mailserver.relay.enable {
      "/var/lib/postfix/conf/".d = {
        mode = "0755";
        user = "root";
        group = "root";
      };
      "/var/lib/postfix/conf/sasl_passwd".L.argument = config.sops.templates."postfix-sasl-passwd".path;
    };

    mailserver = {
      enable = true;
      fqdn = "mail.${config.vars.dominio}";
      domains = [ config.vars.dominio ];
      
      accounts = config.mi_mailserver.accounts;

      stateVersion = 4; 

      # Usamos el certificado ACME wildcard
      x509.useACMEHost = "wildcard";

      enableImap = true;
      enableImapSsl = true;
      enableSubmission = true;
      enableSubmissionSsl = true;

      virusScanning = false;
      
      enableNixpkgsReleaseCheck = false;
    };

    myImpermanence.system.directories = [ "/var/lib/dovecot" "/var/lib/postfix" "/var/vmail" ];
  };
}
