{
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
    systemd.user.slices.hyprland-session = {
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
      xdgOpenUsePortal = true; # use xdg-open with xdg-desktop-portal

      configPackages = [ config.programs.hyprland.package ];

      # hyprland portal is already included (provides screen-shareing)
      # gtk is also needed for a file picker
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    # Enable Cosmic-greeter login manager
    services.displayManager.cosmic-greeter.enable = true;
    environment.systemPackages = with pkgs; [
      cosmic-icons
    ];

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
