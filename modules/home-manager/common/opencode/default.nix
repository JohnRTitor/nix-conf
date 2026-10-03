{ pkgs, ... }: {
  home.packages = with pkgs; [
    opencode
  ];

  xdg.configFile."opencode/opencode.json".source = ./opencode.json;
  xdg.configFile."opencode/AGENTS.md".source = ./opencode-agents.md;

  # Prompts are referenced from opencode.json as {file:./prompts/<name>.txt},
  # so they must land next to the config file as real files, not symlinks.
  xdg.configFile."opencode/prompts" = {
    source = ./prompts;
    recursive = true;
  };
}
