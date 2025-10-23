{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Most configuration is enabled in system/file-manager
  home.file.".local/share/nemo/actions/open_in_kitty.nemo_action".source =
    ./open_in_kitty.nemo_action;
}
