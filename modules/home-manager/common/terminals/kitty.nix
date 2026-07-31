{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkIf (config.myOptions.programsSettings.terminal == "kitty") {
  programs.kitty = {
    enable = true;

    package = pkgs.kitty;

    font.package = pkgs.maple-mono.NF;
    font.name = "Maple Mono NF";
    font.size = 16;

    settings = {
      clear_all_shortcuts = "yes";
      kitty_mod = "ctrl+shift";
      wheel_scroll_min_lines = 1;
      window_padding_width = 4;
      confirm_os_window_close = 0;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      mouse_hide_wait = 60;
      cursor_trail = 1;
      tab_fade = 1;
      active_tab_font_style = "bold";
      inactive_tab_font_style = "bold";
      tab_bar_edge = "top";
      tab_bar_margin_width = 0;
      tab_bar_style = "powerline";
      #tab_bar_style = "fade";
      enabled_layouts = "splits";
      open_url_with_default = true;
      detect_urls = true;
      allow_remote_control = true;

      # open_url_with default
      url_prefixes = "file ftp ftps gemini git gopher http https irc ircs kitty sftp ssh";

      # Manually set color scheme to catpuccin-mocha
      # Disabled stylix support
      # The basic colors
      foreground = "#cdd6f4";
      background = "#1e1e2e";
      selection_foreground = "#1e1e2e";
      selection_background = "#f5e0dc";

      # Cursor colors
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";

      # URL underline color when hovering with mouse
      url_color = "#f5e0dc";

      # Kitty window border colors
      active_border_color = "#b4befe";
      inactive_border_color = "#6c7086";
      bell_border_color = "#f9e2af";

      # OS Window titlebar colors
      wayland_titlebar_color = "system";
      macos_titlebar_color = "system";

      # Tab bar colors
      active_tab_foreground = "#11111b";
      active_tab_background = "#cba6f7";
      inactive_tab_foreground = "#cdd6f4";
      inactive_tab_background = "#181825";
      tab_bar_background = "#11111b";

      # Colors for marks (marked text in the terminal)
      mark1_foreground = "#1e1e2e";
      mark1_background = "#b4befe";
      mark2_foreground = "#1e1e2e";
      mark2_background = "#cba6f7";
      mark3_foreground = "#1e1e2e";
      mark3_background = "#74c7ec";

      # The 16 terminal colors
      # black
      color0 = "#45475a";
      color8 = "#585b70";
      # red
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      # green
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      # yellow
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      # blue
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      # magenta
      color5 = "#f5c2e7";
      color13 = "#f5c2e7";
      # cyan
      color6 = "#94e2d5";
      color14 = "#94e2d5";
      # white
      color7 = "#bac2de";
      color15 = "#a6adc8";
    };

    keybindings = {
      # Clipboard
      "kitty_mod+c" = "copy_to_clipboard";
      "kitty_mod+v" = "paste_from_clipboard";
      "kitty_mod+s" = "paste_from_selection";
      "shift+insert" = "paste_from_selection";

      # Scrolling
      "kitty_mod+up" = "scroll_line_up";
      "kitty_mod+k" = "scroll_line_up";
      "kitty_mod+down" = "scroll_line_down";
      "kitty_mod+j" = "scroll_line_down";
      "kitty_mod+page_up" = "scroll_page_up";
      "kitty_mod+page_down" = "scroll_page_down";
      "kitty_mod+home" = "scroll_home";
      "kitty_mod+end" = "scroll_end";
      "kitty_mod+h" = "show_scrollback";

      # Window management
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+w" = "close_window";
      "kitty_mod+\\" = "launch --location=vsplit --cwd=current";
      "kitty_mod+-" = "launch --location=hsplit --cwd=current";
      "kitty_mod+]" = "next_window";
      "kitty_mod+[" = "previous_window";
      "kitty_mod+f" = "move_window_forward";
      "kitty_mod+b" = "move_window_backward";
      "kitty_mod+`" = "move_window_to_top";
      "kitty_mod+r" = "start_resizing_window";

      # Tab management
      "kitty_mod+right" = "next_tab";
      "kitty_mod+left" = "previous_tab";
      "kitty_mod+t" = "new_tab_with_cwd";
      "kitty_mod+q" = "close_tab";
      "kitty_mod+alt+t" = "set_tab_title";
      "kitty_mod+." = "move_tab_forward";
      "kitty_mod+," = "move_tab_backward";
      "kitty_mod+1" = "goto_tab 1";
      "kitty_mod+2" = "goto_tab 2";
      "kitty_mod+3" = "goto_tab 3";
      "kitty_mod+4" = "goto_tab 4";
      "kitty_mod+5" = "goto_tab 5";
      "kitty_mod+6" = "goto_tab 6";
      "kitty_mod+7" = "goto_tab 7";
      "kitty_mod+8" = "goto_tab 8";
      "kitty_mod+9" = "goto_tab 9";

      # Layout management
      "kitty_mod+l" = "next_layout";
      "kitty_mod+z" = "toggle_layout stack";

      # Miscellaneous
      "kitty_mod+equal" = "increase_font_size";
      "kitty_mod+minus" = "decrease_font_size";
      "kitty_mod+backspace" = "restore_font_size";
    };

    shellIntegration.enableZshIntegration = true;
    shellIntegration.enableFishIntegration = true;
    shellIntegration.enableBashIntegration = true;
    shellIntegration.mode = "enabled";
  };
}
