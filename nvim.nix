{ config, lib, pkgs, ... }:
{
  programs.nvf = {
    enable = true;
    settings.vim = {
      theme.enable = true;
      lsp.enable = true;
    };
  };
}
