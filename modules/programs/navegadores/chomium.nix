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
  options.chromium = {
    enable = lib.mkEnableOption "Activa Chromium con extensiones y políticas";
    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Establece Chromium como navegador predeterminado en XDG MIME";
    };
  };

  config = lib.mkIf config.chromium.enable {
    userPackages.navegadores = [ pkgs.chromium ];
    nixpkgs.config.chromium.commandLineArgs = [ "--force-dark-mode" "--enable-features=WebUIDarkMode" ];

    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
        "edibdbjcniadpccecjdfdjjppcpchdlm" # I still don't care about cookies
      ];
      extraOpts = {
        PasswordManagerEnabled = false;
        DefaultSearchProviderEnabled   = true;
        DefaultSearchProviderName      = "DuckDuckGo";
        DefaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
        DefaultSearchProviderNewTabURL = "https://duckduckgo.com/";
        DefaultSearchProviderKeyword   = "duckduckgo.com";
        BrowserSignin = 0;
        SyncDisabled  = true;
        "3rdparty".extensions = {
          "cjpalhdlnbpafiamejdnhcphjbkeiagm".adminSettings = {
            toOverwrite.filterLists = ublockFilters;
          };
        } // lib.optionalAttrs (config ? vaultwarden && config.vaultwarden.enable) {
          "nngceckbapebfimnlniiiahkandclblb" = bitwardenPolicy;
        };
      };
    };

    xdg.mime = lib.mkIf config.chromium.default {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http"  = "chromium.desktop";
        "x-scheme-handler/https" = "chromium.desktop";
      };
    };

    myImpermanence.users.${user}.directories = [
      ".config/chromium"
      ".cache/chromium"
    ];
  };
}
