{ lib, config, ... }:
let
  inherit (import ../utils/lua.nix { inherit lib; }) mkBind dspExec mkLuaInline;
  inherit (config.myOptions.userSettings.${config.home.username}) default-browser;
  inherit (config.myOptions.programsSettings) statusbar terminal;

  workspaces = builtins.genList (x: builtins.toString (x + 1)) 9;

  noctaliaBind = lib.optionals (statusbar == "noctalia") [
    (mkBind ''mainMod .. " + d"'' "Noctalia Launcher" (dspExec "noctalia msg panel-toggle launcher")
      { }
    )

    # (mkBind ''mainMod .. " + m"'' "Noctalia Notifications"
    #   (dspExec "noctalia-shell ipc call notifications toggleHistory")
    #   { }
    # )
    (mkBind ''mainMod .. " + v"'' "Noctalia Clipboard" (dspExec "noctalia msg panel-toggle clipboard")
      { }
    )
    (mkBind ''mainMod .. " + ALT + p"'' "Noctalia Settings" (dspExec "noctalia msg settings-toggle")
      { }
    )
    (mkBind ''mainMod .. " + SHIFT + comma"'' "Noctalia Settings"
      (dspExec "noctalia msg settings-toggle")
      { }
    )
    (mkBind ''mainMod .. " + CTRL + l"'' "Noctalia Lock Screen" (dspExec "noctalia msg session lock")
      { }
    )
    (mkBind ''mainMod .. " + SHIFT + w"'' "Noctalia Wallpaper"
      (dspExec "noctalia msg panel-toggle wallpaper")
      { }
    )
    (mkBind ''mainMod .. " + x"'' "Noctalia Power Menu" (dspExec "noctalia msg panel-toggle session   ")
      { }
    )
    (mkBind ''mainMod .. " + c"'' "Noctalia Control Center"
      (dspExec "noctalia msg panel-toggle control-center")
      { }
    )
    # (mkBind ''mainMod .. " + CTRL + r"'' "Noctalia Screen Recorder"
    #   (dspExec "noctalia-shell ipc call screenRecorder toggle")
    #   { }
    # )
    (mkBind ''mainMod .. " + SHIFT + r"'' "Restart Noctalia Shell"
      (dspExec "systemctl --user restart noctalia.service")
      { }
    )

    # Toggle the launcher using only mainMod
    (mkBind ''mainMod .. " + " .. mainMod .. "_L"'' "Noctalia Launcher Toggle"
      (dspExec "noctalia msg panel-toggle launcher")
      { release = true; }
    )
  ];

  rofiBind = lib.optionals (statusbar != "noctalia") [
    (mkBind ''mainMod .. " + d"'' "Rofi Launcher" (dspExec "rofi-launcher") { })
    (mkBind ''mainMod .. " + SHIFT + return"'' "Rofi Launcher" (dspExec "rofi-launcher") { })
  ];

  rofiClipboardBind = lib.optionals (statusbar != "noctalia") [
    (mkBind ''mainMod .. " + v"'' "Clipboard History"
      (dspExec "cliphist list | rofi -dmenu | cliphist decode | wl-copy")
      { }
    )
  ];

  workspaceBinds = lib.concatMap (id: [
    (mkBind ''mainMod .. " + ${id}"'' "Workspace ${id}"
      (mkLuaInline "hl.dsp.focus({ workspace = ${id} })")
      { }
    )
    (mkBind ''mainMod .. " + SHIFT + ${id}"'' "Move to Workspace ${id}"
      (mkLuaInline "hl.dsp.window.move({ workspace = ${id} })")
      { }
    )
  ]) workspaces;

in
{
  wayland.windowManager.hyprland.settings = {
    mainMod = {
      _var = "SUPER";
    };

    bind =
      noctaliaBind
      ++ rofiBind
      ++ rofiClipboardBind
      ++ workspaceBinds
      ++ [
        # ── Workspace Overview ──────────────────────────────────────────────
        # (mkBind ''mainMod .. " + CTRL + d"'' "Toggle Dock" (dspExec "dock") { })
        (mkBind ''mainMod .. " + tab"'' "QS Overview" (dspExec "qs ipc -c overview call overview toggle")
          { }
        )

        # ── Terminals ───────────────────────────────────────────────────────
        (mkBind ''mainMod .. " + return"'' "Terminal"
          (dspExec "systemd-run --user --scope --slice=app.slice ${terminal}")
          { }
        )

        # ── Application Launchers ───────────────────────────────────────────
        (mkBind ''mainMod .. " + SHIFT + d"'' "Discord" (dspExec "discord") { })
        (mkBind ''mainMod .. " + ALT + w"'' "Web Search" (dspExec "web-search") { })
        (mkBind ''mainMod .. " + SHIFT + n"'' "Notification Reset" (dspExec "swaync-client -rs") { })
        (mkBind ''mainMod .. " + w"'' "Web Browser" (dspExec "${default-browser}") { })
        (mkBind ''mainMod .. " + y"'' "File Manager" (dspExec "kitty -e yazi") { })

        # ── Screenshots ─────────────────────────────────────────────────────
        (mkBind ''"Print"'' "Screenshot Region" (dspExec "screenshootin --silent") { })
        (mkBind ''mainMod .. " + Print"'' "Screenshot Fullscreen" (dspExec "screenshootin --fullscreen")
          { }
        )
        (mkBind ''mainMod .. " + s"'' "Screenshot Region" (dspExec "screenshootin") { })
        (mkBind ''mainMod .. " + SHIFT + s"'' "Screenshot Fullscreen" (dspExec "screenshootin --fullscreen")
          { }
        )
        (mkBind ''mainMod .. " + ALT + s"'' "Screenshot Fullscreen (5 secs timer)"
          (dspExec "screenshootin --fullscreen --timer 5")
          { }
        )

        # (mkBind ''mainMod .. " + o"'' "OBS Studio" (dspExec "obs") { })
        (mkBind ''mainMod .. " + ALT + c"'' "Color Picker" (dspExec "hyprpicker -a") { })
        # (mkBind ''mainMod .. " + g"'' "GIMP" (dspExec "gimp") { })
        # (mkBind ''mainMod .. " + ALT + m"'' "Audio Control" (dspExec "pwvucontrol") { })

        # ── Window Management ───────────────────────────────────────────────
        (mkBind ''mainMod .. " + q"'' "Kill Active Window" (mkLuaInline "hl.dsp.window.close()") { })
        (mkBind ''mainMod .. " + p"'' "Pseudo Tile" (mkLuaInline "hl.dsp.window.pseudo()") { })
        (mkBind ''mainMod .. " + SHIFT + i"'' "Toggle Split" (mkLuaInline "hl.dsp.layout(\"togglesplit\")")
          { }
        )
        (mkBind ''mainMod .. " + f"'' "Maximize" (mkLuaInline "hl.dsp.window.fullscreen()") { })
        (mkBind ''mainMod .. " + SHIFT + f"'' "Toggle Floating"
          (mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
          { }
        )

        (mkBind ''"CTRL + ALT + delete"'' "Force Logout" (mkLuaInline "hl.dsp.exit()") { })

        # ── Window Movement ─────────────────────────────────────────────────
        (mkBind ''mainMod .. " + SHIFT + left"'' "Move Left"
          (mkLuaInline "hl.dsp.window.move({ direction = \"left\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + right"'' "Move Right"
          (mkLuaInline "hl.dsp.window.move({ direction = \"right\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + up"'' "Move Up"
          (mkLuaInline "hl.dsp.window.move({ direction = \"up\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + down"'' "Move Down"
          (mkLuaInline "hl.dsp.window.move({ direction = \"down\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + h"'' "Move Left (VI)"
          (mkLuaInline "hl.dsp.window.move({ direction = \"left\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + l"'' "Move Right (VI)"
          (mkLuaInline "hl.dsp.window.move({ direction = \"right\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + k"'' "Move Up (VI)"
          (mkLuaInline "hl.dsp.window.move({ direction = \"up\" })")
          { }
        )
        (mkBind ''mainMod .. " + SHIFT + j"'' "Move Down (VI)"
          (mkLuaInline "hl.dsp.window.move({ direction = \"down\" })")
          { }
        )

        # ── Window Swapping ─────────────────────────────────────────────────
        (mkBind ''mainMod .. " + ALT + left"'' "Swap Left"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"left\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + right"'' "Swap Right"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"right\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + up"'' "Swap Up"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"up\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + down"'' "Swap Down"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"down\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + code:43"'' "Swap Left (VI)"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"left\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + code:46"'' "Swap Right (VI)"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"right\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + code:45"'' "Swap Up (VI)"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"up\" })")
          { }
        )
        (mkBind ''mainMod .. " + ALT + code:44"'' "Swap Down (VI)"
          (mkLuaInline "hl.dsp.window.swap({ direction = \"down\" })")
          { }
        )

        # ── Focus Movement ──────────────────────────────────────────────────
        (mkBind ''mainMod .. " + left"'' "Focus Left" (mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
          { }
        )
        (mkBind ''mainMod .. " + right"'' "Focus Right"
          (mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
          { }
        )
        (mkBind ''mainMod .. " + up"'' "Focus Up" (mkLuaInline "hl.dsp.focus({ direction = \"up\" })") { })
        (mkBind ''mainMod .. " + down"'' "Focus Down" (mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
          { }
        )
        (mkBind ''mainMod .. " + h"'' "Focus Left (VI)"
          (mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
          { }
        )
        (mkBind ''mainMod .. " + l"'' "Focus Right (VI)"
          (mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
          { }
        )
        (mkBind ''mainMod .. " + k"'' "Focus Up (VI)" (mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
          { }
        )
        (mkBind ''mainMod .. " + j"'' "Focus Down (VI)"
          (mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
          { }
        )

        # ── Special Workspace ───────────────────────────────────────────────
        (mkBind ''mainMod .. " + SHIFT + space"'' "Move to Scratchpads Workspace"
          (mkLuaInline ''hl.dsp.window.move({ workspace = "special:scratchpads" })'')
          { }
        )
        (mkBind ''mainMod .. " + space"'' "Toggle Scratchpads"
          (mkLuaInline ''hl.dsp.workspace.toggle_special("scratchpads")'')
          { }
        )

        # ── Workspace Navigation ────────────────────────────────────────────
        (mkBind ''mainMod .. " + CTRL + right"'' "Next Workspace"
          (mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
          { }
        )
        (mkBind ''mainMod .. " + CTRL + left"'' "Previous Workspace"
          (mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
          { }
        )

        # ── Scrolling Layout Navigation ─────────────────────────────────────
        (mkBind ''mainMod .. " + mouse_up"'' "Move to Next Column"
          (mkLuaInline "hl.dsp.layout(\"move +col\")")
          { }
        )
        (mkBind ''mainMod .. " + mouse_down"'' "Move to Previous Column"
          (mkLuaInline "hl.dsp.layout(\"move -col\")")
          { }
        )
        (mkBind ''mainMod .. " + period"'' "Swap Column Right" (mkLuaInline "hl.dsp.layout(\"swapcol r\")")
          { }
        )
        (mkBind ''mainMod .. " + comma"'' "Swap Column Left" (mkLuaInline "hl.dsp.layout(\"swapcol l\")")
          { }
        )
        (mkBind ''mainMod .. " + slash"'' "Promote to New Column" (mkLuaInline "hl.dsp.layout(\"promote\")")
          { }
        )

        # ── Window Cycling ──────────────────────────────────────────────────
        (mkBind ''"ALT + tab"'' "Cycle Next Window" (mkLuaInline "hl.dsp.window.cycle_next()") { })
        (mkBind ''"ALT + tab"'' "Bring Active To Top" (mkLuaInline "hl.dsp.window.bring_to_top()") { })

        # ── Media & Hardware Controls ───────────────────────────────────────
        (mkBind ''"XF86AudioRaiseVolume"'' "Volume Up" (dspExec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
          { }
        )
        (mkBind ''"XF86AudioLowerVolume"'' "Volume Down"
          (dspExec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
          { }
        )
        (mkBind ''"XF86AudioMute"'' "Mute Toggle" (dspExec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
          { }
        )
        (mkBind ''"XF86AudioPlay"'' "Play/Pause" (dspExec "playerctl play-pause") { })
        (mkBind ''"XF86AudioPause"'' "Play/Pause" (dspExec "playerctl play-pause") { })
        (mkBind ''"XF86AudioNext"'' "Next Track" (dspExec "playerctl next") { })
        (mkBind ''"XF86AudioPrev"'' "Previous Track" (dspExec "playerctl previous") { })
        (mkBind ''"XF86MonBrightnessDown"'' "Brightness Down" (dspExec "brightnessctl set 5%-") { })
        (mkBind ''"XF86MonBrightnessUp"'' "Brightness Up" (dspExec "brightnessctl set +5%") { })

        # ── Mouse binds ───────────────────────────────────────────────
        (mkBind ''mainMod .. " + mouse:272"'' "Move Window" (mkLuaInline "hl.dsp.window.drag()") {
          mouse = true;
        })
        (mkBind ''mainMod .. " + mouse:273"'' "Resize Window" (mkLuaInline "hl.dsp.window.resize()") {
          mouse = true;
        })
      ];
  };
}
