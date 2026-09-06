{ pkgs, lib, config, ... }:
let
  user = config.usuarioPrincipal;
in
{
  options.keepassxc = {
    enable = lib.mkEnableOption "Activa cliente KeePassXC";
  };

  config = lib.mkIf config.keepassxc.enable {
    userPackages.seguridad = [ pkgs.keepassxc ];

    environment.etc."xdg/keepassxc/keepassxc.ini".text = ''
      [GUI]
      ApplicationTheme=dark

      [Security]
      LockDatabaseIdle=false
      LockDatabaseIdleSeconds=0
      LockDatabaseMinimize=false
      LockDatabaseScreenLock=false
      LockDatabaseOnUserSwitch=false

      [SSHAgent]
      Enabled=true
    '';

    myImpermanence.users.${user}.directories = [
      ".config/keepassxc"
    ];
  };
}
