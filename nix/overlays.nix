{ workmux }:
final: _: {
  # Upstream's test suite has a timing-sensitive test that fails in the nix sandbox.
  workmux = workmux.packages.${final.stdenv.hostPlatform.system}.default.overrideAttrs {
    doCheck = false;
  };
}
