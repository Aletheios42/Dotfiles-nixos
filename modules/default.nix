{ lib, ... }:
let
  discoveredDirs = [ ./core ./programs ./services ./infra ./scripts ];

  excludedFiles = [ "menu.nix" "open-design.nix" "nvim-config.nix" ];

  discoverModules = dir:
    let
      entries = builtins.readDir dir;
      files = lib.filterAttrs (name: type:
        lib.hasSuffix ".nix" name
        && lib.match "default.nix" name == null
        && ! (lib.elem name excludedFiles)
        && "regular" == type
      ) entries;
      subdirs = lib.filterAttrs (name: type:
        type == "directory"
        && builtins.pathExists (dir + "/${name}/default.nix")
      ) entries;
      fileModules = map (name: dir + "/${name}") (lib.attrNames files);
      dirModules = map (name: dir + "/${name}") (lib.attrNames subdirs);
    in
    fileModules ++ dirModules;
in
{
  imports = lib.concatMap discoverModules discoveredDirs;
}
