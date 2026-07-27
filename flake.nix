{
  description = "Mi Configuracion de nixos vainilla";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    open-design = {
      url = "github:nexu-io/open-design";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango-wm = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-index-database, nvf, impermanence, disko, sops-nix, simple-nixos-mailserver, open-design, mango-wm, noctalia, ...}:
  let
    commonModules = [
      nix-index-database.nixosModules.nix-index
      nvf.nixosModules.default
      impermanence.nixosModules.impermanence
      disko.nixosModules.disko
      sops-nix.nixosModules.sops
      simple-nixos-mailserver.nixosModules.default
      mango-wm.nixosModules.mango
      noctalia.nixosModules.default
    ];
  in {
    nixosModules.default = import ./modules/default.nix;

    nixosConfigurations = {
      machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit open-design mango-wm noctalia; };
        modules = [ ./hosts/machine/configuration.nix ] ++ commonModules;
      };

      server1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit noctalia; };
        modules = [ ./hosts/server1/configuration.nix ] ++ commonModules;
      };
    };

    apps.x86_64-linux =
      let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        swayConfig = import ./modules/programs/escritorio/sway-config.nix { inherit pkgs; };
        screenshot-standalone = pkgs.writeShellApplication {
          name = "screenshot-wayland";
          runtimeInputs = [ pkgs.grim pkgs.slurp ];
          text = ''
            mkdir -p "$HOME/Pantallazos"
            grim -g "$(slurp)" "$HOME/Pantallazos/$(date +%Y-%m-%d_%H-%M-%S).png"
          '';
        };
        toggle-record-standalone = pkgs.writeShellApplication {
          name = "toggle-record-wayland";
          runtimeInputs = [ pkgs.wf-recorder pkgs.slurp ];
          text = ''
            if pgrep wf-recorder > /dev/null; then
              pkill wf-recorder
            else
              mkdir -p "$HOME/Grabaciones"
              wf-recorder -g "$(slurp)" -f "$HOME/Grabaciones/$(date +%Y-%m-%d_%H-%M-%S).mp4"
            fi
          '';
        };
      in
      {
        sway = {
          type = "app";
          program =
            let
              wrapped = pkgs.writeShellApplication {
                name = "sway";
                runtimeInputs = [
                  pkgs.sway pkgs.waybar pkgs.rofi pkgs.wofi pkgs.swaylock
                  pkgs.wl-clipboard pkgs.brightnessctl pkgs.wireplumber
                  screenshot-standalone toggle-record-standalone
                ];
                text = ''
                  exec sway --config ${pkgs.writeText "sway-config" swayConfig}
                '';
              };
            in
            "${wrapped}/bin/sway";
        };
        niri = {
          type = "app";
          program = "${pkgs.niri}/bin/niri";
        };
        mango = {
          type = "app";
          program = "${mango-wm.packages.x86_64-linux.default}/bin/mango";
        };
        noctalia = {
          type = "app";
          program = "${noctalia.packages.x86_64-linux.default}/bin/noctalia";
        };
        nvim = let
          nvimPkg = nvf.lib.neovimConfiguration {
            inherit pkgs;
            modules = [ (import ./modules/programs/nvim-config.nix { inherit pkgs; }) ];
          };
        in {
          type = "app";
          program = "${nvimPkg.neovim}/bin/nvim";
        };
      };
  };
}
