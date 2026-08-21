{ pkgs, lib, config, ... }:
let
  rangerConf = pkgs.writeText "rc.conf" ''
    set show_hidden true
    set preview_images true
    set preview_images_method kitty
    map f shell find . -name "%s"
    map yy copy
    map dd cut
    map pp paste
  '';
in
{
  options.shell.ranger = lib.mkOption { type = lib.types.bool; default = true; description = "activa ranger"; };

  config = lib.mkIf config.shell.ranger {
    userPackages.ranger = [
      (pkgs.symlinkJoin {
        name = "ranger";
        paths = [ pkgs.ranger pkgs.kitty ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ranger --add-flags "--cmd='source ${rangerConf}'"
        '';
      })
    ];
  };
}
