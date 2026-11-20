{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rust-anything";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "erkamyaman";
    repo = "rust-anything";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rpS/O4C5+pC8cIXFgkamk2+hwo5tnyFeoKTQs4cUZYE=";
  };

  # Recursive hash of the cargo-vendored dependency tree; the build reports
  # the expected value on a mismatch, so update it there.
  cargoHash = "sha256-VTtOEhsa6psMIfTSaQSQJq0IcR/L8bVQVMK35SBzDKY=";

  # The crate's own test suite spawns `/bin/echo` and exercises host-process
  # behavior that the Nix build sandbox restricts, so it cannot run during
  # the package build.
  doCheck = false;

  meta = {
    description = "Rewrite your app in Rust, one piece at a time, checked against the original's recorded behavior at every step. TypeScript/JavaScript, Python, C, Go, Ruby and Java";
    homepage = "https://github.com/erkamyaman/rust-anything";
    license = lib.licenses.mit;
    mainProgram = "rust-anything";
  };
})
