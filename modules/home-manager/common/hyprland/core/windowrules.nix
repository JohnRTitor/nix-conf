_: {
  wayland.windowManager.hyprland = {
    settings.window_rule = [
      {
        name = "Dialog boxes";
        match = {
          modal = "true";
        };
        tag = "+dialog";
      }

      {
        name = "Picture-in-Picture";
        match = {
          title = "^(Picture-in-Picture|Picture in picture)$";
        };
        keep_aspect_ratio = true;
        tag = "+pip";
      }

      {
        name = "Google Meet Popup";
        match = {
          title = "^(Meet - [a-z]{3}-[a-z]{4}-[a-z]{3})$";
          # class = "^(google-chrome)$"; # disabled so we can match for each browser
        };
        keep_aspect_ratio = false;
        tag = "+pip";
      }

      {
        name = "Screenshare Dialog";
        match = {
          title = "^(Select what to share)$";
        };
        tag = "+dialog";
      }

      {
        name = "Add-Folder";
        match = {
          initial_title = "(Add Folder to Workspace)";
        };
        float = true;
        size = "70% = 60%";
      }

      {
        name = "Open-File";
        match = {
          initial_title = "(Open Files)";
        };
        float = true;
        size = "70% = 60%";
      }

      {
        name = "Wants-to-Save";
        match = {
          initial_title = "(wants to save)";
        };
        float = true;
      }

      {
        name = "Authentication-Required";
        match = {
          title = "^(Authentication Required)$";
        };
        tag = "+dialog";
      }

      {
        name = "MetaMask";
        match = {
          # title = "^(MetaMask)$"; # for some reason, this doesn't work
          class = "^(chrome-nkbihfbeogaeaoehlefnkodbefgpgknn-Default)$";
        };
        tag = "+dialog";
      }

      {
        name = "Resolve";
        match = {
          class = "^(\\bresolve\\b)$";
          xwayland = "1";
        };
        no_blur = true;
      }

      {
        name = "Thunar";
        match = {
          class = "^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$";
        };
        tag = "+file-manager";
      }

      {
        name = "Terminals";
        match = {
          class = "^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm|dropterminal)$";
        };
        tag = "+terminal";
      }

      {
        name = "Brave-browser";
        match = {
          class = "^(Brave-browser(-beta|-dev|-unstable)?)$";
        };
        tag = "+browser";
      }

      {
        name = "Firefox";
        match = {
          class = "^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$";
        };
        tag = "+browser";
      }

      {
        name = "Google-chrome";
        match = {
          class = "^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$";
        };
        tag = "+browser";
      }

      {
        name = "Thorium-browser";
        match = {
          class = "^([Tt]horium-browser|[Cc]achy-browser)$";
        };
        tag = "+browser";
      }

      {
        name = "vscodium";
        match = {
          class = "^(codium|codium-url-handler|VSCodium)$";
        };
        tag = "+projects";
      }

      {
        name = "vscode";
        match = {
          class = "^(VSCode|code-url-handler)$";
        };
        tag = "+projects";
      }

      {
        name = "antigravity";
        match = {
          class = "^(antigravity|antigravity-url-handler)$";
        };
        tag = "+projects";
      }

      {
        name = "jetbrains";
        match = {
          class = "^(jetbrains-.+)$";
        };
        tag = "+projects";
      }

      {
        name = "zed-editor";
        match = {
          class = "^(dev.zed.Zed)$";
        };
        tag = "+projects";
      }

      {
        name = "Discord";
        match = {
          class = "^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$";
        };
        tag = "+im";
      }

      {
        name = "Ferdium";
        match = {
          class = "^([Ff]erdium)$";
        };
        center = true;
        float = true;
        size = "60% = 70%";
        tag = "+im";
      }

      {
        name = "Whatsapp";
        match = {
          class = "^([Ww]hatsapp-for-linux)$";
        };
        tag = "+im";
      }

      {
        name = "Telegram-desktop";
        match = {
          class = "^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$";
        };
        tag = "+im";
      }

      {
        name = "teams-for-linux";
        match = {
          class = "^(teams-for-linux)$";
        };
        tag = "+im";
      }

      {
        name = "gamescope";
        match = {
          class = "^(gamescope)$";
        };
        tag = "+games";
      }

      {
        name = "steam-app";
        match = {
          class = "^(steam_app\\d+)$";
        };
        tag = "+games";
      }

      {
        name = "Steam";
        match = {
          class = "^([Ss]team)$";
        };
        tag = "+gamestore";
      }

      {
        name = "Lutris";
        match = {
          title = "^([Ll]utris)$";
        };
        tag = "+gamestore";
      }

      {
        name = "heroicgameslauncher";
        match = {
          class = "^(com.heroicgameslauncher.hgl)$";
        };
        tag = "+gamestore";
      }

      {
        name = "gnome-disks";
        match = {
          class = "^(gnome-disks|wihotspot(-gui)?)$";
        };
        tag = "+settings";
      }

      {
        name = "rofi";
        match = {
          class = "^([Rr]ofi)$";
        };
        tag = "+settings";
        no_blur = false;
      }

      {
        name = "FileRoller";
        match = {
          class = "^(file-roller|org.gnome.FileRoller)$";
        };
        tag = "+settings";
      }

      {
        name = "NetworkManger";
        match = {
          class = "^(nm-applet|nm-connection-editor|blueman-manager)$";
        };
        tag = "+settings";
      }

      {
        name = "Noctalia Settings";
        match = {
          class = "^(dev.noctalia.Noctalia.Settings)$";
        };
        center = true;
        tag = "+settings";
        no_blur = false;
      }

      {
        name = "PulseAudio/Pipewire Volume Control";
        match = {
          class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$";
        };
        center = true;
        tag = "+settings";
        no_blur = false;
      }

      {
        name = "nwg-look";
        match = {
          class = "^(nwg-look|qt5ct|qt6ct|[Yy]ad)$";
        };
        tag = "+settings";
      }

      {
        name = "xdg-desktop-portal-gtk";
        match = {
          class = "(xdg-desktop-portal-gtk)";
        };
        tag = "+settings";
      }

      {
        name = "blueman";
        match = {
          class = "(.blueman-manager-wrapped)";
        };
        tag = "+settings";
      }

      {
        name = "nwg-displays";
        match = {
          class = "(nwg-displays)";
        };
        tag = "+settings";
      }

      {
        name = "ThunarFileMgr";
        match = {
          class = "([Tt]hunar)";
          title = "negative:(.*[Tt]hunar.*)";
        };
        center = true;
        float = true;
      }

      {
        name = "IdleInhibit-fullscreen-1";
        match = {
          class = "^(*)$";
        };
        idle_inhibit = "fullscreen";
      }

      {
        name = "IdleInhibit-fullscreen-2";
        match = {
          title = "^(*)$";
        };
        idle_inhibit = "fullscreen";
      }

      {
        name = "IdleInhibit-fullscreen-3";
        match = {
          fullscreen = "1";
        };
        idle_inhibit = "fullscreen";
      }

      {
        name = "Settings-Tag";
        match = {
          tag = "settings*";
        };
        float = true;
        opacity = "0.8 0.7";
        size = "70% = 70%";
        no_blur = false;
      }

      {
        name = "WayPaper";
        match = {
          class = "^([Ww]aypaper)$";
        };
        float = true;
        no_blur = false;
      }

      {
        name = "mpv-or-clapper";
        match = {
          class = "^(mpv|com.github.rafostar.Clapper)$";
        };
        float = true;
      }

      {
        name = "codium-url-handler";
        match = {
          class = "(codium|codium-url-handler|VSCodium)";
          title = "negative:(.*codium.*|.*VSCodium.*)";
        };
        float = true;
      }

      {
        name = "heroicgameslauncher-1";
        match = {
          class = "^(com.heroicgameslauncher.hgl)$";
          title = "negative:(Heroic Games Launcher)";
        };
        float = true;
      }

      {
        name = "Steam";
        match = {
          class = "^([Ss]team)$";
          title = "negative:^([Ss]team)$";
        };
        float = true;
      }

      {
        name = "Dialog";
        match = {
          tag = "dialog*";
        };
        center = true;
        float = true;
      }

      {
        name = "Picture in Picture";
        match = {
          tag = "pip*";
        };
        float = true;
        move = "72% = 7%";
        opacity = "0.95 0.75";
        pin = "0";
      }

      {
        name = "Browsers";
        match = {
          tag = "browser*";
        };
        opacity = "1.0 1.0";
      }

      {
        name = "Projects";
        match = {
          tag = "projects*";
        };
        opacity = "0.9 0.8";
      }

      {
        name = "Instant-Messaging";
        match = {
          tag = "im*";
        };
        opacity = "0.94 0.86";
      }

      {
        name = "File-Managers";
        match = {
          tag = "file-manager*";
        };
        opacity = "0.9 0.8";
      }

      {
        name = "Terminals-opacity";
        match = {
          tag = "terminal*";
        };
        opacity = "0.8 0.7";
        no_blur = false;
      }

      {
        name = "windowrule-77";
        match = {
          class = "^(gedit|org.gnome.TextEditor|mousepad)$";
        };
        opacity = "0.8 0.7";
      }

      {
        name = "windowrule-78";
        match = {
          class = "^(seahorse)$";
        };
        opacity = "0.9 0.8";
      }

      {
        name = "windowrule-79";
        match = {
          tag = "games*";
        };
        no_blur = true;
      }

      {
        name = "windowrule-80";
        match = {
          tag = "games*";
        };
        fullscreen = true;
      }

      {
        name = "qs-keybinds";
        match = {
          title = "^(Hyprland Keybinds|Emacs Leader Keybinds|Kitty Configuration|WezTerm Configuration|Ghostty Configuration|Yazi Configuration)$";
        };
        float = true;
        center = true;
        size = "55% = 66%";
      }

      {
        name = "qs-cheatsheets";
        match = {
          title = "^(Cheatsheets Viewer)$";
        };
        float = true;
        center = true;
        size = "65% = 60%";
      }

      {
        name = "qs-extended-viewers";
        match = {
          title = "^(Hyprland Keybinds|Niri Keybinds|BSPWM Keybinds|i3 Keybinds|Sway Keybinds|DWM Keybinds|Emacs Leader Keybinds|Kitty Configuration|WezTerm Configuration|Ghostty Configuration|Yazi Configuration|Cheatsheets Viewer|Documentation Viewer)$";
        };
        float = true;
        center = true;
        size = "55% = 66%";
      }

      {
        name = "QS-Wallpapers";
        match = {
          class = "^(org\\.qt-project\\.qml)$";
          title = "^(Wallpapers)$";
        };
        border_size = 0;
        float = true;
        no_blur = true;
        no_shadow = true;
        rounding = 12;
      }

      {
        name = "QA-Video-Wallpapers";
        match = {
          class = "^(org\\.qt-project\\.qml)$";
          title = "^(Video Wallpapers)$";
        };
        border_size = 0;
        center = true;
        float = true;
        no_blur = true;
        no_shadow = true;
        rounding = 12;
      }

      {
        name = "QS-wlogout";
        match = {
          class = "^(org\\.qt-project\\.qml)$";
          title = "^(qs-wlogout)$";
        };
        border_size = 0;
        center = true;
        float = true;
        opacity = "1.0 1.0";
        rounding = 20;
      }

      {
        name = "QA-Panels";
        match = {
          class = "^(org\\.qt-project\\.qml)$";
          title = "^(Panels)$";
        };
        center = true;
        float = true;
        no_blur = true;
        no_shadow = true;
        rounding = 12;
      }

      {
        name = "QS-Cheatsheets";
        match = {
          class = "^(org\\.qt-project\\.qml)$";
          title = "^(Cheatsheets Viewer)$";
        };
        border_size = 0;
        center = true;
        float = true;
        no_shadow = true;
        rounding = 12;
      }

      {
        name = "QS-Documentation-Viewer";
        match = {
          class = "^(org\\.qt-project\\.qml)$";
          title = "^(Documentation Viewer)$";
        };
        border_size = 0;
        center = true;
        float = true;
        no_shadow = true;
        rounding = 12;
      }
    ];
  };
}
