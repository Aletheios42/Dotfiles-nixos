{ lib, pkgs, ... }:

let
    terminal = "kitty";
    mod = "Mod4";
in
{
    # --- i3 CONFIG ---
    xsession = {
        enable = true;
        scriptPath = ".xinitrc";
        windowManager.i3 = {
            enable = true;

            config = {
                modifier = mod;
                terminal = terminal;
                menu = "dmenu_run";
                bars = [ { statusCommand = "${pkgs.i3status}/bin/i3status"; } ];
                
                keybindings = lib.mkOptionDefault {
                    # Focus
                    "${mod}+l" = "focus left";
                    "${mod}+k" = "focus up";
                    "${mod}+j" = "focus down";
                    "${mod}+h" = "focus right";

                    # Move window
                    "${mod}+shift+l" = "move left";
                    "${mod}+shift+k" = "move up";
                    "${mod}+shift+j" = "move down";
                    "${mod}+shift+h" = "move right";

                    # Brillo
                    "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
                    "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

                    # Audio
                    "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+";
                    "XF86AudioLowerVolume" =  "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-";
                    "XF86AudioMute" =  "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                    "XF86AudioMicMute" =  "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

                    # Bloqueo
                    "${mod}+Escape" = "exec i3lock";

                    #Pantallazo
                    "${mod}+Print" = "exec screenshot-x11";
                    "${mod}+shift+Print" = "exec toggle-record-x11";
                };
            };
        };
    };
}
