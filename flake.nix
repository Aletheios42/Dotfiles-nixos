{
	description = "Configuracion de nixos con flakes y homemanager"

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

		home-manager.url = "github:nix-community/home-manager";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	}


	outputs = { self, nixpkgs, home-manager, } @inputs: {
		nixosConfigurations = {
			aletheios42 = nixpkgs.lib.nixosSystem {
					system = "x86_64-linux";
					specialArgs = { inherit inputs; }
					modules = [
						./configuration.nix

						home-manager.nixosModules.home-manager
						{
							home-manager.useGlobalPkgs = true;
							home-manager.useUserPackages = true;
							home-manager.users.aletheios42 = import ./home.nix;
						}
					]
				}
			}
		}
	}
}
