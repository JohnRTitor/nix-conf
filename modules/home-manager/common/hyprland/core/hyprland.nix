{
  config,
  pkgs,
  lib,
  ...
}:
let
  vars = import ../../../../variables.nix;
  keyboardLayout = vars.keyboardLayout or "us";
  keyboardVariant = vars.keyboardVariant or "";

  # Treat only known US-based variants as implying layout = "us".
  usVariants = [
    "dvorak"
    "colemak"
    "workman"
    "intl"
    "us-intl"
    "altgr-intl"
  ];
  normalizeUSVariant = v: if v == "us-intl" then "intl" else v;

  # If layout itself is a US variant (e.g., "dvorak", "us-intl"), normalize it
  layoutFromLayout = if builtins.elem keyboardLayout usVariants then "us" else keyboardLayout;
  variantFromLayout =
    if builtins.elem keyboardLayout usVariants then normalizeUSVariant keyboardLayout else "";

  # If the provided variant is a US variant, force layout to us; otherwise keep layout
  layoutFromVariant = if builtins.elem keyboardVariant usVariants then "us" else layoutFromLayout;
  variantFinal =
    if builtins.elem keyboardVariant usVariants then
      normalizeUSVariant keyboardVariant
    else if variantFromLayout != "" then
      variantFromLayout
    else
      keyboardVariant;

  hyprKbLayout = layoutFromVariant;
  hyprKbVariant = variantFinal;
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "1";
        supports_wide_color = true;
      }
      {
        output = "Virtual-1";
        mode = "1920x1080@60";
        position = "auto";
        scale = "1";
        supports_wide_color = true;
      }
    ];

    layer_rule = [
      {
        blur = true;
        match.namespace = "waybar";
      }
    ];

    config = {
      input = (
        {
          kb_layout = hyprKbLayout;
          kb_options = lib.concatStringsSep ", " [
            "grp:alt_caps_toggle"
            # Enabling this makes caps lock act like super key
            # "caps:super"
          ];
          numlock_by_default = true;
          repeat_delay = 300;
          follow_mouse = 1;
          float_switch_override_focus = 0;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 0.8;
          };
        }
        // lib.optionalAttrs (hyprKbVariant != "") { kb_variant = hyprKbVariant; }
      );

      gestures = {
        gesture = [ "3, horizontal, workspace" ];
        workspace_swipe_distance = 500;
        workspace_swipe_invert = true;
        workspace_swipe_min_speed_to_force = 30;
        workspace_swipe_cancel_ratio = 0.5;
        workspace_swipe_create_new = true;
        workspace_swipe_forever = true;
      };

      scrolling = {
        column_width = 0.80;
        fullscreen_on_one_column = true;
        direction = "right";
        follow_focus = true;
      };

      monocle = { };

      general = {
        layout = "scrolling";
        gaps_in = 6;
        gaps_out = 8;
        border_size = 2;
        resize_on_border = true;
        "col.active_border" = "rgb(${config.lib.stylix.colors.base08})";
        "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
      };

      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vrr = 2; # Variable Refresh Rate  Might need to set to 0 for NVIDIA/AQ_DRM_DEVICES
        # Screen flashing to black momentarily or going black when app is fullscreen
        # Try setting vrr to 0

        #  Application not responding (ANR) settings
        enable_anr_dialog = true;
        anr_missed_pings = 15;
      };

      dwindle = {
        preserve_split = true;
        smart_resizing = true;
        use_active_for_splits = true;
        smart_split = false;
        default_split_ratio = 1.0;
        split_bias = 0;
        precise_mouse_move = false;
        special_scale_factor = 0.8;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
      };

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        warp_on_change_workspace = 2;
        no_warps = true;
      };

      render = {
        # Disabling as no longer supported
        #explicit_sync = 1; # Change to 1 to disable
        #explicit_sync_kms = 1;
        direct_scanout = 0;
      };

      master = {
        new_status = "slave";
        new_on_top = false;
        new_on_active = "none";
        orientation = "left";
        mfact = 0.55;
        slave_count_for_center_master = 2;
        center_master_fallback = "left";
        smart_resizing = true;
        drop_at_cursor = true;
        always_keep_position = false;
      };

      # Ensure Xwayland windows render at integer scale; compositor scales them
      xwayland.force_zero_scaling = true;
    };
  };
}
