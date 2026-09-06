{ pkgs, lib, config, ...}:
{
  options.sistema = {
    enable = lib.mkEnableOption "Variables";
    version = lib.mkOption {
      type = lib.types.str;
      description = "Versión de NixOS desde la instalación inicial. NO cambiar tras el primer deploy.";
    };
  };

  config = lib.mkIf (config.sistema.enable) {
    assertions = [{
      assertion = config.sistema.version != "";
      message = "sistema.version no puede estar vacío";
    }];

    system.stateVersion = config.sistema.version;
    nix.settings.download-buffer-size = 524288000; # 500MB
    nix.settings.experimental-features = ["nix-command" "flakes" "configurable-impure-env"];
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
      impure-env = [ "NIXPKGS_ALLOW_UNFREE=1" ];
    };
    environment.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };
    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "root" "@wheel" ];

    programs.nix-index.enable = true;
    programs.nix-index-database.comma.enable = true;
    programs.nix-index.enableZshIntegration = true;

    i18n.defaultLocale = "es_ES.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS        = "es_ES.UTF-8";
      LC_IDENTIFICATION = "es_ES.UTF-8";
      LC_MEASUREMENT    = "es_ES.UTF-8";
      LC_MONETARY       = "es_ES.UTF-8";
      LC_NAME           = "es_ES.UTF-8";
      LC_NUMERIC        = "es_ES.UTF-8";
      LC_PAPER          = "es_ES.UTF-8";
      LC_TELEPHONE      = "es_ES.UTF-8";
      LC_TIME           = "es_ES.UTF-8";
    };

    environment.systemPackages = [
      pkgs.python3
      pkgs.git
      pkgs.neovim
      pkgs.openssl
      pkgs.zip pkgs.unzip
      pkgs.btop pkgs.systemd-manager-tui  pkgs.wget 
      pkgs.ethtool pkgs.dnsutils pkgs.net-tools pkgs.fping pkgs.netcat
      pkgs.xdg-user-dirs
    ];

    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };

    environment.variables = {
      EDITOR    = "nvim";
      VISUAL    = "nvim";
      PAGER     = "less";
      MANPAGER  = "less";
      GTK_THEME = "Adwaita:dark";
    };
    environment.shellAliases = {};
    environment.pathsToLink = [ "/share/zsh" ];
  };
}
