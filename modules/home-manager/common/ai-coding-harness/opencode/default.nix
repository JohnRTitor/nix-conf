{ pkgs, ... }: {
  home.packages = with pkgs; [
    opencode
  ];

  xdg.configFile."opencode/opencode.json".source = ./opencode.json;
  xdg.configFile."opencode/AGENTS.md".source = ./opencode-agents.md;

  # The workflow skill bundled with rust-anything (v2.0.2), installed for OpenCode.
  xdg.configFile."opencode/skills/rust-anything" = {
    source = ./skills/rust-anything;
    recursive = true;
  };

  # Prompts are referenced from opencode.json as {file:./prompts/<name>.txt},
  # so they must land next to the config file as real files, not symlinks.
  xdg.configFile."opencode/prompts" = {
    source = ./prompts;
    recursive = true;
  };
}
