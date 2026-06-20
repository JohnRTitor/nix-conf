{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    package = inputs.noctalia.packages.${pkgs.system}.default;
  };

  # Install the Noctalia package and service
  systemd.user.services.noctalia = {
    Unit = {
      After = [ "hyprland-session.target" ];
      BindsTo = [ "hyprland-session.target" ];
      PartOf = [ "hyprland-session.target" ];
      Requisite = [ "hyprland-session.target" ];

      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
    Service = {
      Environment = [
        "PATH=\"/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin\""
      ];
      Slice = "hyprland.slice";
    };
  };

  home.packages = with pkgs; [
    matugen # color palette generator needed for noctalia-shell
    app2unit # launcher for noctalia-shell

    ## GPU SCREEN RECORDER, used in a plugin, disabled here, as
    # this is enabled in a system module
    # gpu-screen-recorder
  ];
}
