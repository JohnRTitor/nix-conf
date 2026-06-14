{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ micro-with-wl-clipboard ];
  environment.sessionVariables = {
    EDITOR = "micro";
  };
}
