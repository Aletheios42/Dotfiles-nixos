{ pkgs, lib, config, ... }:
{
  options.comunicacion.cliente = lib.mkEnableOption "Descarga paquetes basicos de comunicacion";

  config = lib.mkIf (config.comunicacion.cliente) {
    userPackages.comunicacion = [
      pkgs.discord
      pkgs.whatsie
      (pkgs.symlinkJoin {
        name = "slack-dark";
        paths = [ pkgs.slack ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/slack \
            --add-flags "--force-dark-mode"
        '';
      })
      pkgs.telegram-desktop
      pkgs.weechat
      pkgs.element-desktop
    ];

    myImpermanence.users.${config.usuarioPrincipal} = {
      directories = [
        ".config/discord"
        ".config/WhatSie"
        ".local/share/org.keshavnrj.ubuntu"
        ".config/Slack"
        ".config/telegram-desktop"
        ".local/share/TelegramDesktop"
        ".weechat"
        ".config/Element"
      ];
    };
  };
}
