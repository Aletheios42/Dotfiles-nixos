{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
    ../../modules/default.nix
    ../../modules/services/open-design.nix
  ];

  vars = {
    dominio = "alejandropintosalcarazo.com";
  };

  services.guix.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  impermanencia = {
    enable = true;
    dispositivo = "/dev/mapper/crypted";
  };

  mi_sops = {
    enable = true;
    secretsFile = ../../secrets/machine.yaml;
    useSshKey = true;
  };

  sistema.enable = true;
  sistema.version = "26.05";
  arranque = {
    enable = true;
    loader = "monolito";
  };
  red = {
    enable = true;
    hostname = "machine";
    timeZone = "Europe/Madrid";
    puertosPermitidos = [ 80 443 8621 8889 8890 11111 ];
  };

  usuarios = {
    aletheios42 = {
      hashedPassword = "$6$p7IwCtyd.a9aWxQ7$7curRU6NV9aUqMq4h7T0814y5jSPDDcrJpvBiLPADtnrc.kHPv8P2FsUQ06oAw1/hriWmQgoKujDQkhBV.3II1";
      llavesSsh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBNAFtwsoBJcft2fw5ds2h0QnShb9osnxWVyMsBnClH aletheios42" ];
      grupos = [ "wheel" "networkmanager" "video" "input" "audio" "docker" "uucp" "dialout" "libvirtd" ];
      shell = pkgs.zsh;
    };
  };

  # hacer serccion de paquetes de dev
  userPackages.aletheios42 = [ pkgs.gnumake pkgs.gdb pkgs.gcc pkgs.sops pkgs.wget pkgs.btop pkgs.age pkgs.magic-wormhole-rs pkgs.pandoc pkgs.zk];

  shell = {
    enable = true;
    zsh = true;
    ranger = true;
    kitty = true;
    cli = true;
    tmux = true;
    direnv = true;
  };
  editor.enable = true;

  mi_ssh = {
    enable = true;
    cliente.enable = true;
    servidor = {
      enable = true;
      puertos = [1234];
    };
  };

  escritorio = {
    enable = true;
    mango = true;
    sway = true;
    # niri = true;
    noctalia = true;
  };

  virtualizacion = {
    enable = true;
    docker = true;
    podman = true;
    qemu = true;
  };

  git = {
    enable = true;
    name = "aletheios42";
  };

  documentacion.enable = true;

  mi_postgres.enable = true;

  ai = {
    enable = true;
    opencode.enable = true;
    litellm.enable = true;
    llama = {
      fim = {
        enable = true;
        port   = 8080;
        host   = "127.0.0.1";
        model  = "qwen2.5-coder-1.5b-instruct-q4_k_m.gguf";
      };
      work = {
        enable = true;
        port   = 8081;
        host   = "127.0.0.1";
      };
    };
  };

  opendesign = {
    enable = true;
    port   = 7457;
  };

  bluetooth.enable = true;
  audio.enable = true;
  pantalla.enable = true;

  media = {
    enable = true;
    cliente = true;
    grayjay = true;
    obs.enable = true;
  };

  pkm = {
    enable = true;
    dir = "/home/aletheios42/Documentos/Pkm/";
    zk = true;
    obsidian = true;
  };

  passwords = {
    enable = true;
    keepassxc = true;
  };

  comunicacion = {
    enable = true;
    discord = true;
    whatsie = true;
    slack = true;
    telegram = true;
    thunderbird = true;
    weechat = true;
    element = true;
  };

  navegadores = {
    enable = true;
    firefox = true;
    chromiun = true;
    tor = true;
    qutebrowser = true;
  };

  lectura = {
    enable = true;
    zathura = true;
    calibre = true;
    koreader = true;
  };

  android.enable = true;

  myImpermanence.users.aletheios42.directories = [
    "Documentos"
    "Multimedia"
  ];
}
