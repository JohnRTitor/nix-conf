{
  adminer-pematon,
  fetchFromGitHub,
}:
adminer-pematon.overrideAttrs (
  finalAttrs: oldAttrs: {
    pname = oldAttrs.pname + "-with-theme";

    adminerThemeVersion = "1.8.1";
    # https://github.com/pematon/adminer-theme
    adminerTheme = fetchFromGitHub {
      owner = "pematon";
      repo = "adminer-theme";
      rev = "v${finalAttrs.adminerThemeVersion}";
      hash = "sha256-Ax0UfqBF7xzYDGU5OlYCxq+9SzvXw7/WI7GJiXpZXBk=";
    };

    # Installs the adminer theme
    # Modifies the index.php to include the theme using sed
    # substituteInPlace won't work here as it can't interprete \t \n
    # sed -i '/return new \\AdminerPlugin($plugins);/i \\t    $plugins[] = new \\AdminerTheme();' $out/index.php
    # or we can replace the index.php with the one that includes the theme
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        cp -r ${finalAttrs.adminerTheme}/lib/* $out/
        rm $out/index.php
        cp ${./index.php} $out/index.php
      '';
  }
)
