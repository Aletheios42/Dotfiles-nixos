{ lib, ... }:
let
  discoveredDirs = [ ./core ./programs ./services ./infra ./scripts ];

  excludedFiles = [ "menu.nix" ];

  discoverModules = dir:
    let
      entries = builtins.readDir dir;
      files = lib.filterAttrs (name: type:
        lib.hasSuffix ".nix" name
        && ! (lib.elem name excludedFiles)
        && "regular" == type
      ) entries;
      subdirs = lib.filterAttrs (name: type:
        type == "directory"
      ) entries;
      fileModules = map (name: dir + "/${name}") (lib.attrNames files);
      subdirModules = lib.concatMap (name: discoverModules (dir + "/${name}")) (lib.attrNames subdirs);
    in
      fileModules ++ subdirModules;

in
  {
  imports = lib.concatMap discoverModules discoveredDirs;
}
