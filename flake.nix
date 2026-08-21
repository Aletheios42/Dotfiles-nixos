{
  description = "Mi Configuracion de nixos vainilla";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    stylix = { url = "github:danth/stylix"; inputs.nixpkgs.follows = "nixpkgs"; };
    nix-index-database = { url = "github:nix-community/nix-index-database"; inputs.nixpkgs.follows = "nixpkgs"; };
    nvf = { url = "github:notashelf/nvf"; inputs.nixpkgs.follows = "nixpkgs"; };
    impermanence.url = "github:nix-community/impermanence";
    disko = { url = "github:nix-community/disko"; inputs.nixpkgs.follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix"; inputs.nixpkgs.follows = "nixpkgs"; };
    simple-nixos-mailserver = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; inputs.nixpkgs.follows = "nixpkgs"; };
    open-design = { url = "github:nexu-io/open-design"; inputs.nixpkgs.follows = "nixpkgs"; };
    mango-wm = { url = "github:mangowm/mango"; inputs.nixpkgs.follows = "nixpkgs"; };
    noctalia = { url = "github:noctalia-dev/noctalia"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { nixpkgs, nix-index-database, nvf, impermanence, disko, sops-nix, simple-nixos-mailserver, open-design, mango-wm, noctalia, stylix, ... }:
    let
      system = "x86_64-linux";
      commonModules = [
        nix-index-database.nixosModules.nix-index
        nvf.nixosModules.default
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        simple-nixos-mailserver.nixosModules.default
        mango-wm.nixosModules.mango
        noctalia.nixosModules.default
        stylix.nixosModules.stylix
      ];
    in {
      nixosConfigurations = {
        machine = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit open-design mango-wm noctalia; };
          modules = [ ./hosts/machine/configuration.nix ] ++ commonModules;
        };
        server1 = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit noctalia; };
          modules = [ ./hosts/server1/configuration.nix ] ++ commonModules;
        };
      };
    };
}
