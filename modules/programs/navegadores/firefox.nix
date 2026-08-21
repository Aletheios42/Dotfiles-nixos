{ pkgs, lib, config, ... }:
let
  user = config.vars.usuarioPrincipal;

  vaultwardenUrl = "https://${config.vaultwarden.subdominio}.${config.vars.dominio}";
  bitwardenPolicy = {
    environment = {
      base = vaultwardenUrl;
    };
  };

  ublockFilters = [
    "user-filters" "ublock-filters" "ublock-badware" "ublock-privacy"
    "ublock-quick-fixes" "ublock-unbreak" "easylist" "easyprivacy"
    "urlhaus-1" "plowe-0"
    "adguard-cookies" "fanboy-cookiemonster" "ublock-annoyances"
  ];
in
{
  options.firefox = {
    enable = lib.mkEnableOption "Activa Firefox con políticas declarativas";
    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Establece Firefox como navegador predeterminado en XDG MIME";
    };
  };

  config = lib.mkIf config.firefox.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox;
      policies = {
        PasswordManagerEnabled = false;
        SearchEngines = {
          Default = "DuckDuckGo";
          PreventInstalls = true;
        };
        Preferences = {
          "ui.systemUsesDarkTheme"      = 1;
          "browser.theme.content-theme" = 0;
          "browser.theme.toolbar-theme" = 0;
          "browser.download.dir"        = "/home/${user}/Downloads";
          "browser.download.folderList" = 2;
        };
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
          };
          "idcac-pub@guus.ninja" = {
            install_url       = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
            installation_mode = "force_installed";
          };
        };
        "3rdparty".Extensions = {
          "uBlock0@raymondhill.net".adminSettings = {
            toOverwrite.filterLists = ublockFilters;
          };
        } // lib.optionalAttrs (config ? vaultwarden && config.vaultwarden.enable) {
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = bitwardenPolicy;
        };
      };
    };

    xdg.mime = lib.mkIf config.firefox.default {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http"  = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };

    myImpermanence.users.${user}.directories = [
      ".mozilla/firefox"
      "Downloads"
    ];
  };
}
