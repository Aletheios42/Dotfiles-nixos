{ pkgs, lib, config, ... }:
{
  options.shell.kitty = lib.mkOption { type = lib.types.bool; default = true; description = "activa terminal kitty"; };

  config = lib.mkIf config.shell.kitty {
    userPackages.kitty = [ pkgs.kitty ];
    environment.variables.TERM = "xterm-256color";
    console.keyMap = "es";
    console.earlySetup = true;
    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono pkgs.nerd-fonts.fira-code pkgs.nerd-fonts.dejavu-sans-mono ];
    system.activationScripts.kittyConfig = {
      deps = [ "users" ];
      text = ''
        KITTY_CFG="/home/${config.vars.usuarioPrincipal}/.config/kitty"
        mkdir -p "$KITTY_CFG"
        cat > "$KITTY_CFG/kitty.conf" << 'KITTYEOF'
scrollback_lines -1
enable_audio_bell no
confirm_os_window_close 0
map shift+enter send_text all \x1b\r
KITTYEOF
        chown ${config.vars.usuarioPrincipal}:users "$KITTY_CFG/kitty.conf"
      '';
    };
    myImpermanence.users.${config.vars.usuarioPrincipal}.directories = [ ".config/kitty" ];
  };
}
