{
  self,
  lib,
  pkgs,
  config,
  ...
}:
let
  enableUSWM = false;
in
lib.mkMerge [
  {
    systemd.user.slices.hyprland = {
      description = "Essential desktop services for Hyprland (OOM-proof)";
      sliceConfig = {
        MemoryAccounting = true;
        ManagedOOMPreference = "omit";
        OOMScoreAdjust = "-800";
      };
    };

    ## Configure XDG portal ##
    xdg.portal = {
      enable = true;

      extraPortals = lib.mkForce [
        config.programs.hyprland.portalPackage
        self.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-gtk4

      ];

      # hyprland portal is already included (provides screen-sharing)
      # gtk is also needed for a file picker
      config.hyprland = {
        default = [
          "hyprland"
          "gtk4"
        ];

        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.ScreenShot" = [ "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk4" ];
      };
    };

    # Run XDG autostart, this is needed for a DE-less setup like Hyprland
    services.xserver.desktopManager.runXdgAutostartIfNone = true;
  }

  (lib.mkIf enableUSWM {
    # this adds a new UWSM managed Hyprland session
    # that properly starts Hyprland compositor with
    # `graphical-session.target` and necessary services
    # graphical-session.target is managed by hyprland nixos module
    programs.uwsm.enable = true;
    programs.uwsm.package = pkgs.uwsm;
    programs.uwsm.waylandCompositors = {
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/start-hyprland";
      };
    };
  })
]
