# Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  # SYSTEM
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Configuration of GRUB
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot/";
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.efiInstallAsRemovable = true; 
  boot.loader.grub.extraEntries = ''
    menuentry "Windows 11" {
    search --set=root --file /EFI/Microsoft/Boot/bootmgfw-original.efi
    chainloader /EFI/Microsoft/Boot/bootmgfw-original.efi
    }
   '';

  # --- Sistema de archivos ---
  boot.supportedFilesystems = ["ntfs"];
  fileSystems."/home/aletheios42/Comunes" = {
    device = "/dev/disk/by-uuid/B6864A79864A39DF";
    fsType = "ntfs-3g";
    options = [
        "rw"
        "nofail"
        "uid=1000"
        "gid=1000"
        "umask=0022"
    ];
  };

  # ---  Bluetooth ---
  hardware.bluetooth.enable = true;

  # ---  RED ---
  networking.hostName = "machine";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Madrid";
  i18n.defaultLocale = "es_ES.UTF-8";

  # --- CONSOLA & KEYMAP ---
  console.earlySetup = true; #Aplica key repeat y dealy en las tty
  console.useXkbConfig = true; # Copia layout de Xserver
  ## mirar si esto esta duplicado con i3.nix
  services.xserver = {
    enable = true;
    xkb.layout = "es"; # Esto configura Xorg y Consola
    displayManager.startx.enable = true; 
    # Gestores de ventanas
    windowManager.i3.enable = true;
    autoRepeatDelay = 250;
    autoRepeatInterval = 20; # (Ojo: en Xserver esto es 1000/Frecuencia)
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # --- FUENTES ---
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # --- AUDIO  ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; # Compatibilidad con apps viejas y OBS
  };

  # --- VIRTUALIZACIÓN & CONTENEDORES ---
  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd.enable = true;
  };
  programs.dconf.enable = true; # Necesario para muchas apps GUI (virt-manager)

  # --- SHELL & USUARIO ---
  programs.zsh.enable = true;
  
  users.users.aletheios42 = {
    isNormalUser = true;
    initialPassword = "1234";
    extraGroups = [ "wheel" "networkmanager" "video" "input" "audio" "docker" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # Base de datos de paquetes
  programs.nix-index.enable = true; # tienes nix-locate y nix-index
  programs.nix-index-database.comma.enable = true; # Opcional: permite usar "," para ejecutar cosas no instaladas
  programs.nix-index.enableBashIntegration = true; # Completion de paquetes en bash
  programs.nix-index.enableZshIntegration = true; # Completion de paquetes en zsh

  # --- GNU --- 
  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.perf 
    showmethekey
    bc
  ];

  # perf sin sudo para debug
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = -1;
  };
}
