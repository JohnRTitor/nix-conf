{ pkgs, ... }:

{
  xdg.configFile."micro/syntax" = {
    source = "${pkgs.micro.src}/runtime/syntax";
    recursive = true;
  };
}
