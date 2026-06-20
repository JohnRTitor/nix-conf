# Configure hyprland window manager
# this config file contains package, portal and services declaration
# made specifically for hyprland
{
  self,
  config,
  lib,
  pkgs,
  pkgs-master,
  inputs,
  ...
}:
let

  mk_desktop_entry =
    opts:
    (pkgs.writeTextFile {
      name = "${opts.name}";
      text = ''
        [Desktop Entry]
        Name=${opts.prettyName}
        Comment=${opts.comment}
        Exec=${opts.binPath}
        Type=Application
      '';
      destination = "/share/wayland-sessions/${opts.name}.desktop";
      derivationArgs = {
        passthru.providedSessions = [ "${opts.name}" ];
      };
    });

  waylandCompositors = {
    hyprland = {
      name = "hyprland-oom-resistant";
      prettyName = "Hyprland (OOM Resistant)";
      comment = "Hyprland compositor launched using systemd";
      # See status using `systemctl --user status hyprland-session.scope`
      binPath = ''systemd-run --user --scope --slice=hyprland.slice --unit=hyprland-session --property="ManagedOOMPreference=omit" "/run/current-system/sw/bin/start-hyprland"'';
    };
  };
in
{
  imports = [
    ./session.nix
    ./programs
  ];

  # Enable Hyprland Window Manager
  programs.hyprland = {
    enable = true;

    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  services.displayManager.sessionPackages = lib.mapAttrsToList (
    name: value:
    mk_desktop_entry {
      inherit name;
      inherit (value)
        prettyName
        comment
        binPath
        extraArgs
        ;
    }
  ) waylandCompositors;

  # No need for XWayland Satellite on Hyprland
  programs.xwayland.enable = true;
}
