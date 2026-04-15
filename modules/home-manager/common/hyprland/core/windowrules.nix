_: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      # Set float and centering for dialog boxes
      rule = float(true), match:modal:1
      rule = center(true), match:modal:1

      windowrule {
        name = Resolve
        match:class = ^(\bresolve\b)$
        match:xwayland = 1
        no_blur = on
      }

      windowrule {
        name = Thunar
        match:class = ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$
        tag = +file-manager
      }

      windowrule {
        name = Terminals
        match:class = ^(com.mitchellh.ghostty|org.wezfurlong.wezterm|Alacritty|kitty|kitty-dropterm|dropterminal)$
        tag = +terminal
      }

      windowrule {
        name = Brave-browser
        match:class = ^(Brave-browser(-beta|-dev|-unstable)?)$
        tag = +browser
      }

      windowrule {
        name = Firefox
        match:class = ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$
        tag = +browser
      }

      windowrule {
        name = Google-chrome
        match:class = ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$
        tag = +browser
      }

      windowrule {
        name = Thorium-browser
        match:class = ^([Tt]horium-browser|[Cc]achy-browser)$
        tag = +browser
      }

      windowrule {
        name = vscodium
        match:class = ^(codium|codium-url-handler|VSCodium)$
        tag = +projects
      }

      windowrule {
        name = vscode
        match:class = ^(VSCode|code-url-handler)$
        tag = +projects
      }

      windowrule {
        name = zed-editor
        match:class = ^(dev.zed.Zed)$
        tag = +projects
      }

      windowrule {
        name = Discord
        match:class = ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$
        tag = +im
      }

      windowrule {
        name = Ferdium
        match:class = ^([Ff]erdium)$
        center = on
        float = on
        size = 60% = 70%
        tag = +im
      }

      windowrule {
        name = Whatsapp
        match:class = ^([Ww]hatsapp-for-linux)$
        tag = +im
      }

      windowrule {
        name = Telegram-desktop
        match:class = ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$
        tag = +im
      }

      windowrule {
        name = teams-for-linux
        match:class = ^(teams-for-linux)$
        tag = +im
      }

      windowrule {
        name = gamescope
        match:class = ^(gamescope)$
        tag = +games
      }

      windowrule {
        name = steam-app
        match:class = ^(steam_app\d+)$
        tag = +games
      }

      windowrule {
        name = Steam
        match:class = ^([Ss]team)$
        tag = +gamestore
      }

      windowrule {
        name = Lutris
        match:title = ^([Ll]utris)$
        tag = +gamestore
      }

      windowrule {
        name = heroicgameslauncher
        match:class = ^(com.heroicgameslauncher.hgl)$
        tag = +gamestore
      }

      windowrule {
        name = gnome-disks
        match:class = ^(gnome-disks|wihotspot(-gui)?)$
        tag = +settings
      }

      windowrule {
        name = rofi
        match:class = ^([Rr]ofi)$
        tag = +settings
        no_blur = off
      }

      windowrule {
        name = FileRoller
        match:class = ^(file-roller|org.gnome.FileRoller)$
        tag = +settings
      }

      windowrule {
        name = NetworkManger
        match:class = ^(nm-applet|nm-connection-editor|blueman-manager)$
        tag = +settings
      }

      windowrule {
        name = PlusAudio
        match:class = ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$
        center = on
        tag = +settings
        no_blur = off
      }

      windowrule {
        name = nwg-look
        match:class = ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$
        tag = +settings
      }

      windowrule {
        name = xdg-desktop-portal-gtk
        match:class = (xdg-desktop-portal-gtk)
        tag = +settings
      }

      windowrule {
        name = blueman
        match:class = (.blueman-manager-wrapped)
        tag = +settings
      }

      windowrule {
        name = nwg-displays
        match:class = (nwg-displays)
        tag = +settings
      }

      windowrule {
        name = Picture-in-Picture
        match:title = ^(Picture-in-Picture)$
        float = on
        move = 72% = 7%
        opacity = 0.95 = 0.75
        pin = 0
        keep_aspect_ratio = on
      }

      windowrule {
        name = ThunarFileMgr
        match:class = ([Tt]hunar)
        match:title = negative:(.*[Tt]hunar.*)
        center = on
        float = on
      }

      windowrule {
        name = Authentication-Required
        match:title = ^(Authentication Required)$
        center = on
        float = on
      }

      windowrule {
        name = IdleInhibit-fullscreen-1
        match:class = ^(*)$
        idle_inhibit = fullscreen
      }

      windowrule {
        name = IdleInhibit-fullscreen-2
        match:title = ^(*)$
        idle_inhibit = fullscreen
      }

      windowrule {
        name = IdleInhibit-fullscreen-3
        match:fullscreen = 1
        idle_inhibit = fullscreen
      }

      windowrule {
        name = Settings-Tag
        match:tag = settings*
        float = on
        opacity = 0.8 = 0.7
        size = 70% = 70%
        no_blur = off
      }

      windowrule {
        name = WayPaper
        match:class = ^([Ww]aypaper)$
        float = on
        no_blur = off
      }

      windowrule {
        name = mpv-or-clapper
        match:class = ^(mpv|com.github.rafostar.Clapper)$
        float = on
      }

      windowrule {
        name = codium-url-handler
        match:class = (codium|codium-url-handler|VSCodium)
        match:title = negative:(.*codium.*|.*VSCodium.*)
        float = on
      }

      windowrule {
        name = heroicgameslauncher-1
        match:class = ^(com.heroicgameslauncher.hgl)$
        match:title = negative:(Heroic Games Launcher)
        float = on
      }

      windowrule {
        name = Steam
        match:class = ^([Ss]team)$
        match:title = negative:^([Ss]team)$
        float = on
      }

      windowrule {
        name = Add-Folder
        match:initial_title = (Add Folder to Workspace)
        float = on
        size = 70% = 60%
      }

      windowrule {
        name = Open-File
        match:initial_title = (Open Files)
        float = on
        size = 70% = 60%
      }

      windowrule {
        name = Wants-to-Save
        match:initial_title = (wants to save)
        float = on
      }

      windowrule {
        name = Browsers
        match:tag = browser*
        opacity = 1.0 = 1.0
      }

      windowrule {
        name = Projects
        match:tag = projects*
        opacity = 0.9 = 0.8
      }

      windowrule {
        name = Instant-Messaging
        match:tag = im*
        opacity = 0.94 = 0.86
      }

      windowrule {
        name = File-Managers
        match:tag = file-manager*
        opacity = 0.9 = 0.8
      }

      windowrule {
        name = Terminals-opacity
        match:tag = terminal*
        opacity = 0.8 = 0.7
        no_blur = off
      }

      windowrule {
        name = windowrule-77
        match:class = ^(gedit|org.gnome.TextEditor|mousepad)$
        opacity = 0.8 = 0.7
      }

      windowrule {
        name = windowrule-78
        match:class = ^(seahorse)$
        opacity = 0.9 = 0.8
      }

      windowrule {
        name = windowrule-79
        match:tag = games*
        no_blur = on
      }

      windowrule {
        name = windowrule-80
        match:tag = games*
        fullscreen = on
      }

      windowrule {
        name = qs-keybinds
        match:title = ^(Hyprland Keybinds|Emacs Leader Keybinds|Kitty Configuration|WezTerm Configuration|Ghostty Configuration|Yazi Configuration)$
        float = on
        center = on
        size = 55% = 66%
      }

      windowrule {
        name = qs-cheatsheets
        match:title = ^(Cheatsheets Viewer)$
        float = on
        center = on
        size = 65% = 60%
      }

      windowrule {
        name = qs-extended-viewers
        match:title = ^(Hyprland Keybinds|Niri Keybinds|BSPWM Keybinds|i3 Keybinds|Sway Keybinds|DWM Keybinds|Emacs Leader Keybinds|Kitty Configuration|WezTerm Configuration|Ghostty Configuration|Yazi Configuration|Cheatsheets Viewer|Documentation Viewer)$
        float = on
        center = on
        size = 55% = 66%
      }

      windowrule {
        name = QS-Wallpapers
        match:class = ^(org\.qt-project\.qml)$
        match:title = ^(Wallpapers)$
        border_size = 0
        float = on
        no_blur = on
        no_shadow = on
        rounding = 12
      }

      windowrule {
        name = QA-Video-Wallpapers
        match:class = ^(org\.qt-project\.qml)$
        match:title = ^(Video Wallpapers)$
        border_size = 0
        center = on
        float = on
        no_blur = on
        no_shadow = on
        rounding = 12
      }

      windowrule {
        name = QS-wlogout
        match:class = ^(org\.qt-project\.qml)$
        match:title = ^(qs-wlogout)$
        border_size = 0
        center = on
        float = on
        opacity = 1.0 = 1.0
        rounding = 20
      }

      windowrule {
        name = QA-Panels
        match:class = ^(org\.qt-project\.qml)$
        match:title = ^(Panels)$
        center = on
        float = on
        no_blur = on
        no_shadow = on
        rounding = 12
      }

      windowrule {
        name = QS-Cheatsheets
        match:class = ^(org\.qt-project\.qml)$
        match:title = ^(Cheatsheets Viewer)$
        border_size = 0
        center = on
        float = on
        no_shadow = on
        rounding = 12
      }

      windowrule {
        name = QS-Documentation-Viewer
        match:class = ^(org\.qt-project\.qml)$
        match:title = ^(Documentation Viewer)$
        border_size = 0
        center = on
        float = on
        no_shadow = on
        rounding = 12
      }
    '';
  };
}
