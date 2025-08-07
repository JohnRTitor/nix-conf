{ ... }:
{
  console.earlySetup = true;
  # start after fs have been mounted, else it might fail
  # systemd.services.systemd-vconsole-setup.after = [ "local-fs.target" ];

  # services.gpm.enable = true; # For mouse support in tty console, not needed for me
}
