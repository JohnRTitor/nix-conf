{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  openssl,
}:

buildGoModule (finalAttrs: {
  pname = "firefly-cli";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "hyperledger-firefly";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KDJ9wZxSQdftT50f9EDqzCdcuvuBR03QcpgD3coN/EA=";
  };

  vendorHash = "sha256-kb+081KpzcKUmKw1R/bIDvBy4suBRhW7Iqo8wvFZEe0=";

  # The CLI's main package lives in ./ff and installs the `ff` binary.
  subPackages = [ "ff" ];

  # The test suite spawns Docker containers and pulls manifests from ghcr.io,
  # neither of which is available in the Nix build sandbox.
  doCheck = false;

  ldflags = [
    "-X github.com/hyperledger-firefly/cli/cmd.BuildVersionOverride=${finalAttrs.version}"
  ];

  env.CGO_ENABLED = "0";

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  # `ff` shells out to openssl to generate stack certificates.
  postFixup = ''
    wrapProgram $out/bin/ff --prefix PATH : ${lib.makeBinPath [ openssl ]}
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ff \
      --bash <($out/bin/ff completion bash) \
      --fish <($out/bin/ff completion fish) \
      --zsh <($out/bin/ff completion zsh)
  '';

  meta = {
    description = "CLI for managing local Hyperledger FireFly stacks";
    homepage = "https://github.com/hyperledger-firefly/cli";
    license = lib.licenses.asl20;
    mainProgram = "ff";
  };
})
