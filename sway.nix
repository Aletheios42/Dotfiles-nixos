{ config, lib, pkgs, ... }:

let
    terminal = "kitty";
    mod = "Mod4";
in
{
    # --- SWAY CONFIG ---
    programs.waybar.enable = true;
    wayland.windowManager.sway = {
        enable = true;
        config = {
            modifier = mod;
            terminal = terminal;
            menu = "rofi -show drun";

        input = {
                "type:keyboard" = {
                    xkb_layout = "es";
            repeat_delay = "250";  # Tiempo (ms) que debes mantener la tecla antes de que empiece a repetir 250ms es rápido, 300ms es estándar, 200ms es muy rápido (para pros).
            repeat_rate = "50";   # Cuántas veces se repite la tecla por segundo 25 es estándar, 50 es rápido, 70+ como el demonio.
            };
         };
            output = { "*" = { bg = "#000000 solid_color"; }; };
            bars = [ { command = "${pkgs.waybar}/bin/waybar";} ];
            keybindings = lib.mkOptionDefault {

                # Volumen (Usando wpctl de PipeWire)
                "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%+";
                "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%-";
                "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
                "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";

                # Brillo
                "XF86MonBrightnessUp" = "exec brightnessctl set +5%";
                "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

                # Bloqueo
                "${mod}+Escape" = "exec swaylock -f -c 000000";

        
        
                #Pantallazos y grabaciones
                "${mod}+Print" = "exec screenshot-wayland";
                "${mod}+shift+Print" = "exec toggle-record-wayland";
            };
        };
    };
}
