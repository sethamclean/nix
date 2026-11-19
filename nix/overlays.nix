{ workmux }:
final: prev: {
  # OpenShell 0.1.x is the floor. Use nixpkgs' package once it reaches 0.1.0 or
  # newer (any newer version is fine); until then fall back to our 0.1.x binary.
  openshell =
    if prev ? openshell && final.lib.versionAtLeast prev.openshell.version "0.1.0" then
      prev.openshell
    else
      final.callPackage ./pkgs/openshell.nix { };

  # The gateway and its microVM driver are not in nixpkgs. Their version must match the CLI's,
  # because the CLI, gateway and driver speak one protocol; a mismatch fails at evaluation.
  openshell-gateway =
    let
      gateway = final.callPackage ./pkgs/openshell-gateway.nix { };
    in
    assert final.lib.assertMsg (gateway.version == final.openshell.version)
      "openshell-gateway ${gateway.version} must match openshell ${final.openshell.version}; bump nix/pkgs/openshell-gateway.nix";
    gateway;

  # Development microVM helper: policy and subcommands live in openshell/ and nix/pkgs/box.nix.
  box = final.callPackage ./pkgs/box.nix { };

  # Upstream's test suite has a timing-sensitive test that fails in the nix sandbox.
  workmux = workmux.packages.${final.stdenv.hostPlatform.system}.default.overrideAttrs {
    doCheck = false;
  };
}
