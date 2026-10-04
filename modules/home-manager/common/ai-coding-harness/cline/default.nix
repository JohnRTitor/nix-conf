{
  lib,
  pkgs,
  pkgs-master,
  ...
}:
{
  home.packages = [ pkgs-master.cline ];

  # Cline has no per-agent permission blocks. The only permission control is the
  # CLINE_COMMAND_PERMISSIONS env var (global, shell commands only, deny wins).
  # allowRedirects must be true: it defaults to false, which would block `>` / `<`.
  home.sessionVariables.CLINE_COMMAND_PERMISSIONS = builtins.replaceStrings [ "\"" ] [ "\\\"" ] (
    builtins.toJSON {
      deny = [
        "sudo *"
        "rm -rf *"
        "rm -fr *"
        "git push"
        "git push *"
        "git reset --hard"
        "git reset --hard *"
        "git clean"
        "git clean *"
      ];
      allowRedirects = true;
    }
  );

  # Global rules (always-on), like opencode's AGENTS.md
  home.file.".cline/rules/engineering.md".source = ./rules/engineering.md;

  # Global skills, invoked as /validate-loop and /review-loop.
  # recursive = true makes each skill dir a real directory (files are store symlinks).
  home.file.".cline/skills/validate-loop" = {
    source = ./skills/validate-loop;
    recursive = true;
  };
  home.file.".cline/skills/validate-loop/docs" = {
    source = ./critics;
    recursive = true;
  };
  home.file.".cline/skills/review-loop" = {
    source = ./skills/review-loop;
    recursive = true;
  };
  home.file.".cline/skills/review-loop/docs" = {
    source = ./critics;
    recursive = true;
  };
}
