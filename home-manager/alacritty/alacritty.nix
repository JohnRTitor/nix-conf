# This config file is used to configure alacritty
{ pkgs, userSettings, ... }:
{
  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty.enable = true;
  programs.alacritty.settings = {
    # SETTINGS START
    live_config_reload = true;

    bell = {
      animation = "EaseOutExpo";
      duration = 0;
    };

    colors = {
      draw_bold_text_with_bright_colors = true;
      bright = {
        black = "0x686868";
        blue = "0x57c7ff";
        cyan = "0x9aedfe";
        green = "0x5af78e";
        magenta = "0xff6ac1";
        red = "0xff5c57";
        white = "0xf1f1f0";
        yellow = "0xf3f99d";
      };
      cursor = {
        background = "0x008ec4";
        foreground = "0xf1f1f1";
      };
      normal = {
        black = "0x282a36";
        blue = "0x57c7ff";
        cyan = "0x9aedfe";
        green = "0x5af78e";
        magenta = "0xff6ac1";
        red = "0xff5c57";
        white = "0xf1f1f0";
        yellow = "0xf3f99d";
      };
      primary = {
        background = "0x030215";
        foreground = "0xeff0eb";
      };
    };

    cursor = {
      style = "Block";
      unfocused_hollow = true;
    };

    debug = {
      render_timer = false;
    };

    font = {
      size = 14.5;
      bold = {
        family = "InconsolataLGC Nerd Font";
      };
      glyph_offset = {
        x = 0;
        y = 0;
      };
      italic = {
        family = "InconsolataLGC Nerd Font";
      };
      normal = {
        family = "InconsolataLGC Nerd Font";
      };
      offset = {
        x = 0;
        y = 0;
      };
    };

    mouse = {
      bindings = [
        {
          action = "PasteSelection";
          mouse = "Middle";
        }
      ];
    };

    scrolling = {
      history = 15000;
      multiplier = 3;
    };

    selection = {
      save_to_clipboard = false;
      semantic_escape_chars = ",│`|:\"' ()[]{}<>";
    };

    shell = {
      program = if (userSettings.shell == "zsh") then
                  "/run/current-system/sw/bin/zsh"
                else "/run/current-system/sw/bin/bash";
    };

    window = {
      decorations = "Full";
      dynamic_title = true;
      opacity = 0.95;
      startup_mode = "Maximized";
      padding = {
        x = 2;
        y = 2;
      };
    };
    # SETTINGS END
  };
}