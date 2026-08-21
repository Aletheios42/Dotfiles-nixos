{ pkgs, lib, config, ... }:
let
  labctl = pkgs.buildGoModule rec {
    pname = "labctl";
    version = "0.1.102";
    src = pkgs.fetchFromGitHub {
      owner = "iximiuz"; repo = "labctl"; rev = "v${version}";
      hash = "sha256-jI9nsZOUZGmC5s3NnBh7HGau+xQgKEyyMy04DL4RsvU=";
      # hash = lib.fakeHash;
    };
    vendorHash = "sha256-YNjguFRCgm3W5fsyUXRPXka0sWJUJYCXMhv9tAL+JYU=";
    #vendorHash = lib.fakeHash;
    ldflags = [ "-s" "-w" ];
  };
in
{
  options.labctl.enable = lib.mkEnableOption "activa labctl de iximiuzlabs";

  config = lib.mkIf (config.labctl.enable) {
    environment.systemPackages = [ labctl ];
  };
}
