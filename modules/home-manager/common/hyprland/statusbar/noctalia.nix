{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  noctaliaPkg = pkgs.noctalia-shell;
  configDir = "${noctaliaPkg}/share/noctalia-shell";
in
{
  # Install the Noctalia package and service
  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell Service";
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
      ExecStart = "${noctaliaPkg}/bin/noctalia-shell";
      Restart = "on-failure";
      Environment = [
        "PATH=\"/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin\""
      ];
    };
  };

  home.packages = with pkgs; [
    noctaliaPkg
    quickshell # Ensure quickshell is available for the service

    matugen # color palette generator needed for noctalia-shell
    app2unit # launcher for noctalia-shell
    gpu-screen-recorder # needed for nnoctalia-shell
  ];

  # Seed the configuration
  home.activation.seedNoctaliaShellCode = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    DEST="$HOME/.config/quickshell/noctalia-shell"
    SRC="${configDir}"

    if [ ! -d "$DEST" ]; then
      $DRY_RUN_CMD mkdir -p "$HOME/.config/quickshell"
      $DRY_RUN_CMD cp -R "$SRC" "$DEST"
      $DRY_RUN_CMD chmod -R u+rwX "$DEST"
    fi
  '';
}
