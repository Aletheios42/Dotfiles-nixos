{ config, lib, pkgs, inputs, ... }:

let
  mod = "Mod4";
  terminal = "kitty";
  user = "aletheios42";
  carpeta_musica = "Comunes/Música";
  carpeta_grabaciones = "Comunes/Videos/Grabaciones";
  carpeta_pantallazo = "Comunes/Imagenes/Pantallazos";
in
  {
  imports = [ ./i3.nix ./sway.nix ./nvim.nix  inputs.nvf.homeManagerModules.default ];

  home.username = user;
  home.homeDirectory = "/home/aletheios42";
  home.stateVersion = "25.11";
  manual.manpages.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # --- SSH ---
  services.ssh-agent.enable = true;
  # --- PAQUETERÍA ---
  home.packages = with pkgs; [

    # Lenguages
    go zig rustup python3 lua php elixir julia R ocaml nodejs terraform typst gleam

    # Teclado
    wev xev

    # GUI Básica
    kitty rofi dmenu lxappearance swaylock i3lock

    # Navegadores
    firefox google-chrome chromium brave

    # Brillo
    brightnessctl

    # Multimedia
    vlc mpv ffmpeg-full
    grim slurp # screenshots en Sway
    wf-recorder # Grabar pantalla en sway
    maim slop # screenshots en i3
    simplescreenrecorder # Grabar pantalla en i3
    pavucontrol # Para controlar el volumen gráficamente

    # Portapapeles
    wl-clipboard # Wayland
    xclip xsel # Xorg

    # Social
    discord slack thunderbird

    # Seguridad
    keepassxc

    # Dev Tools C/C++ & Debug
    gcc gnumake cmake
    gdb valgrind
    clang-tools # Incluye clangd, clang-format
    compiledb # Genera compile_commands.json para LSP

    # Notas
    obsidian

    # Redes
    ethtool dnsutils

    # Contenedores
    dive trivy crane nerdctl kubectl

    # Emulacion
    qemu virt-manager

    # Utils
    zathura # PDF Reader minimalista
    ripgrep
    fd
    tree
  ];

  # fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true; # Se conecta con tu Zsh automáticamente

    # Esto hace que fzf use ripgrep (rg) para buscar archivos.
    # Es mucho más rápido y respeta el .gitignore
    defaultCommand = "rg --files --hidden --glob '!.git/*'";
  };

  # Tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];
  };

  # Zsh (Tuneado básico)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Oh-my-zsh integrado
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git" "docker" "sudo"
      ];
      theme = "robbyrussell"; # O "agnoster" si tienes fuentes parcheadas
    };
  };

  # Kitty Beep
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
    };
  };

  # Git
  programs.git = {
    enable = true;
    # En lugar de userName/userEmail/extraConfig sueltos:
    settings = {
      user = {
        name = "aletheios42";
        email = "";
      };
      init.defaultBranch = "master";
      credential.helper = "store";
    };
  };

  # OBS
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      input-overlay
    ];
  };

  # Thunderbird
  programs.thunderbird = {
    enable = true;

    profiles."aletheios42" = {
      isDefault = true;

      settings = {
        # Abrir mensajes en una nueva pestaña
        "mail.openMessageBehavior" = 2;

        # Opcional: Desactiva el panel de vista previa (F8) para que al hacer
        # clic tengas que hacer doble clic para abrir en la pestaña
        "mail.pane_config.dynamic" = 0;

        # --- MODO OSCURO ---
        # Le dice al navegador interno que use el modo oscuro
        "browser.in-content.dark-mode" = true;
        # Fuerza a la UI a pensar que el sistema está en modo oscuro
        "ui.systemUsesDarkTheme" = 1;
        # Activa el tema oscuro por defecto
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
      };
    };
  };
}
