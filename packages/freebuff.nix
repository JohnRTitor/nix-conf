{
  lib,
  stdenvNoCC,
  bun,
  fetchFromGitHub,
  gitMinimal,
  makeBinaryWrapper,
  nodejs,
  ripgrep,
  xdg-utils,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

let
  nodeModules =
    finalAttrs:
    stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-node-modules";
      inherit (finalAttrs) version src;

      __structuredAttrs = true;
      strictDeps = true;

      nativeBuildInputs = [
        bun
        writableTmpDirAsHomeHook
      ];

      dontConfigure = true;

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
      ];

      buildPhase = ''
        runHook preBuild

        export BUN_INSTALL_CACHE_DIR=$(mktemp -d)

        # `--os`/`--cpu` resolve the whole workspace (the CLI, the SDK it
        # bundles, and the agents precompiled into the binary) for every
        # platform we support, so one derivation resolves them all. Without
        # them Bun only resolves the build platform's optional dependencies,
        # which leaves a non-native builder without its native module.
        bun install \
          --frozen-lockfile \
          --ignore-scripts \
          --no-progress \
          --os="*" \
          --cpu="*"

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        find . -type d -name node_modules -exec cp -R --parents {} $out \;

        runHook postInstall
      '';

      # Required, else the fixed-output derivation ends up referencing store
      # paths from the source it was built from.
      dontFixup = true;

      outputHash = "sha256-cFAbx5SE1Vk6eyIW0D4m+znEmwlXjke7RI7KQ1f86qo=";
      outputHashAlgo = "sha256";
      outputHashMode = "recursive";
    };

  # Directory under `sdk/vendor/ripgrep` holding the build for this platform.
  ripgrepTarget =
    (if stdenvNoCC.hostPlatform.isx86_64 then "x64" else "arm64")
    + "-"
    + (if stdenvNoCC.hostPlatform.isDarwin then "darwin" else "linux");
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "freebuff";
  version = "0.2.12";

  __structuredAttrs = true;
  strictDeps = true;

  # The public repository is a mirror of a private one, snapshotted on each
  # push, so it carries no release tags. Its tags follow upstream Codebuff's
  # `v1.0.x` scheme, which does not track Freebuff's own `0.x` npm versions.
  # Pin the snapshot that the `freebuff-v${finalAttrs.version}` npm package, and
  # the GitHub release binaries published under the same tag, were built from.
  src = fetchFromGitHub {
    owner = "CodebuffAI";
    repo = "freebuff";
    rev = "f6c9bf23ecd733d05db82bdabd99521388488a73";
    hash = "sha256-3yVu7dVwQov01wwZ/jWonDc40Yy9ECcnT8I8iDLGn7U=";
  };

  node_modules = nodeModules finalAttrs;

  nativeBuildInputs = [
    bun
    makeBinaryWrapper
    # `dts-bundle-generator`, run by the SDK build, is a Node CLI.
    nodejs
    writableTmpDirAsHomeHook
  ];

  # These are compiled into the executable rather than read from the
  # environment: `cli/scripts/build-binary.ts` turns every `NEXT_PUBLIC_*`
  # variable into a `--define process.env.<NAME>=...` pair, so their values are
  # baked into the JavaScript and cannot be corrected after the fact.
  #
  # The two app URLs are separate hosts serving separate roles, and conflating
  # them breaks login:
  #
  #   NEXT_PUBLIC_CODEBUFF_APP_URL -> the API. Despite the name, Freebuff's
  #     authenticated endpoints (/api/v1/me, /api/v1/usage, the agent runs) live
  #     on the Codebuff origin; freebuff.com answers those with 404. Point this
  #     at `freebuff.com` and every bearer-token request after login 404s.
  #     The `www.` host is the one that serves them, and matches what the
  #     official release binary has compiled in.
  #
  #   NEXT_PUBLIC_FREEBUFF_APP_URL -> the web app the login page is served from
  #     (`FREEBUFF_WEB_URL` in cli/src/login/constants.ts). Left unset it falls
  #     back to FREEBUFF_WEB_URL_PROD, but the official binary sets it
  #     explicitly, so match that.
  #
  # The remaining values are upstream's own production settings. They only have
  # to satisfy the build-time schema in `common/src/env-schema.ts`, except the
  # PostHog key, which is upstream's public write-only project key used for the
  # ads that fund the free tier.
  env = {
    NEXT_PUBLIC_CB_ENVIRONMENT = "prod";
    NEXT_PUBLIC_CODEBUFF_APP_URL = "https://www.codebuff.com";
    NEXT_PUBLIC_FREEBUFF_APP_URL = "https://freebuff.com";
    NEXT_PUBLIC_SUPPORT_EMAIL = "support@codebuff.com";
    NEXT_PUBLIC_POSTHOG_API_KEY = "phc_tug7g8yc10qNestK14QV8WyKwjfEl6vwzIbJkBdqeHS";
    NEXT_PUBLIC_POSTHOG_HOST_URL = "https://us.i.posthog.com";
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY = "pk_live_51Q0SA5KrNS6SjmqWMgRE0ar5v6cMvtizkyY3mXjYaZsU6AG9ctpNPKZMVf6xFK2ngqwkt8rHNIQgNiCFSbRdGb9Z00QEo13rfx";
    NEXT_PUBLIC_STRIPE_CUSTOMER_PORTAL = "https://billing.stripe.com/p/login/cN22bea8W6Ra2is144";
    NEXT_PUBLIC_WEB_PORT = "3000";
    # Selects the free agent catalog over the metered Codebuff one.
    FREEBUFF_MODE = "true";
  };

  postPatch = ''
    # The SDK build ends by generating type declarations, which type-checks the
    # whole workspace and fails on pre-existing errors in packages the CLI does
    # not use. A compiled executable carries no declarations, so this step only
    # gates publishing to npm: warn instead of aborting the build.
    substituteInPlace sdk/scripts/build.ts \
      --replace-fail \
      "console.error('❌ TypeScript declaration bundling failed:', error.message)" \
      "console.error('warning: TypeScript declaration bundling failed:', error.message)" \
      --replace-fail \
      'process.exit(1)' \
      'void 0'

    # `cli/scripts/build-binary.ts` reinstalls the OpenTUI native bundle for the
    # compile target from the network before every build. The dependency
    # derivation already resolved a complete bundle for each platform, so skip
    # the install and use the one on disk.
    substituteInPlace cli/scripts/build-binary.ts \
      --replace-fail \
      'prepareOpenTuiNativeBundle(targetInfo)' \
      '/* disabled: resolved by the node_modules derivation */'
  '';

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .

    # The store hands over a read-only tree, but the build writes into it: the
    # SDK build writes under node_modules and Bun caches next to the packages
    # it resolves.
    find . -type d -name node_modules -prune -exec chmod -R u+w {} +

    patchShebangs node_modules cli sdk

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    # `freebuff/cli/build.ts` wraps the shared CLI build with FREEBUFF_MODE set,
    # which generates the bundled agents, builds the SDK, and compiles the
    # standalone executable.
    bun freebuff/cli/build.ts "${finalAttrs.version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/freebuff
    cp -R cli/bin/. $out/libexec/freebuff/

    # Bun passes `--sourcemap=none` but still drops an `entry.js.map` beside the
    # executable on the 1.3.x series this flake resolves. Upstream's release
    # archives carry only the executable and tree-sitter.wasm, so drop it rather
    # than ship ~21MB of the entire bundled TypeScript sources.
    rm -f $out/libexec/freebuff/*.map

    # The SDK embeds a ripgrep for every platform and the CLI unpacks the
    # matching one next to itself on first use. The store is read-only, so ship
    # it alongside the executable up front: the CLI finds the file already there
    # and skips the extraction entirely.
    cp sdk/vendor/ripgrep/${ripgrepTarget}/rg $out/libexec/freebuff/rg

    makeWrapper $out/libexec/freebuff/freebuff $out/bin/freebuff \
      --prefix PATH : ${
        lib.makeBinPath (
          [
            ripgrep
            gitMinimal
          ]
          ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
            xdg-utils
          ]
        )
      }

    runHook postInstall
  '';

  # Bun-compiled executables do not survive stripping.
  dontStrip = true;

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];
  versionCheckProgramArg = "--version";
  versionCheckKeepEnvironment = "HOME PATH";

  # No updateScript: the source revision is pinned by hand because the public
  # repository carries no tags matching Freebuff's own version scheme (see src),
  # so nix-update-script would follow upstream's unrelated `v1.0.x` tags.

  meta = {
    description = "Free AI coding agent for the terminal";
    longDescription = ''
      Freebuff is a free coding agent that runs in your terminal. It reads and
      edits files, runs commands and works through tasks with you in the loop,
      without requiring a subscription or an API key.
    '';
    homepage = "https://freebuff.com";
    changelog = "https://github.com/CodebuffAI/codebuff-community/releases/tag/freebuff-v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "freebuff";
    maintainers = with lib.maintainers; [ johnrtitor ];
    inherit (bun.meta) platforms;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
