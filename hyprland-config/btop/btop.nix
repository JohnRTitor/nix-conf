# this config file is a wrapper to automatically configure btop
{ pkgs, ... }:
{
  # main config
  home.file.".config/btop/btop.conf".source = ./btop.conf;
  # themes
  home.file.".config/btop/themes/catppuccin_frappe.theme".source = ./themes/catppuccin_frappe.theme;
  home.file.".config/btop/themes/catppuccin_latte.theme".source = ./themes/catppuccin_latte.theme;
  home.file.".config/btop/themes/catppuccin_macchiato.theme".source = ./themes/catppuccin_macchiato.theme;
  home.file.".config/btop/themes/catppuccin_mocha.theme".source = ./themes/catppuccin_mocha.theme;
}