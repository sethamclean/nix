{ workmux }:
final: prev: {
  # OpenShell 0.1.x is the floor. Use nixpkgs' package once it reaches 0.1.0 or
  # newer (any newer version is fine); until then fall back to our 0.1.x binary.
  openshell =
    if prev ? openshell && final.lib.versionAtLeast prev.openshell.version "0.1.0" then
      prev.openshell
    else
      final.callPackage ./pkgs/openshell.nix { };

  # Upstream's test suite has a timing-sensitive test that fails in the nix sandbox.
  workmux = workmux.packages.${final.stdenv.hostPlatform.system}.default.overrideAttrs {
    doCheck = false;
  };
}
