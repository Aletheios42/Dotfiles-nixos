{ pkgs, ... }:
{
imports = (import ./registry.nix) ++ [
  ./hardware-configuration.nix
  ./disk.nix
  ../../modules/services/open-design.nix
];

  # hacer serccion de paquetes de dev
  userPackages.dev = [ pkgs.gnumake pkgs.gdb pkgs.gcc pkgs.btop pkgs.systemd-manager-tui pkgs.magic-wormhole-rs pkgs.wget ];

  sistema =  {
    enable = true;
    version = "26.05";
  };

  myImpermanence.users.aletheios42.directories = [
    "Documentos"
    "Multimedia"
  ];
  impermanencia = {
    enable = true;
    dispositivo = "/dev/mapper/crypted";
  };

  mi_sops = {
    enable = true;
    secretsFile = ../../secrets/machine.yaml;
    useSshKey = true;
  };

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
      llavesSsh = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGpmfb5bZFHDK6zE2cnLWkGJPiSq8lxpSGhOkHKNIxVP Admin" ];
      grupos = [ "wheel" "networkmanager" "video" "input" "audio" "docker" "uucp" "dialout" "libvirtd" ];
      shell = pkgs.zsh;
    };
  };

  shell = {
    zsh = true;
    ranger = true;
    kitty = true;
    tmux = true;
    direnv = false;
    kmscon = false;
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

  bluetooth.enable = true;
  audio.enable = true;

  media.cliente = true;

  pkm = {
    enable = true;
    dir = "/home/aletheios42/Documentos/Pkm/";
    zk = true;
    obsidian = false;
  };

  comunicacion = {
    cliente = true;
    thunderbird = true;
  };

  firefox.enable = true;
  chromium.enable = true;
  tor.enable = true;
  qutebrowser.enable = true;

  lectura = {
    zathura = true;
    calibre = true;
    koreader = true;
  };
  android.enable = true;
  labctl.enable = true;
}
