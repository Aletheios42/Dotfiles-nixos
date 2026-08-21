{ pkgs, config, lib, ...}:
{
  options.estilos.enable = lib.mkEnableOption "Activa estilos para las apps";

  config = lib.mkIf (config.estilos.enable) {
    stylix = {
      enable = true;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      image = /home/aletheios42/Multimedia/Imagenes/Piedad.jpg;

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          applications = 12;
          terminal = 12;
          desktop = 11;
          popups = 12;
        };
      };

      # 5. Opciones avanzadas / Targets del sistema (opcional)
      # Stylix aplicará automáticamente el tema a GRUB/systemd-boot, la TTY, etc.
      # Si quisieras desactivar alguno, puedes hacerlo aquí:
      # targets = {
      #   console.enable = true;
      #   grub.enable = true;
      # };
    };
  };
}
