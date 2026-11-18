{
  lib,
  stdenv,
  fetchurl,
}:
# NVIDIA OpenShell CLI from the upstream release binaries (static on Linux).
# Fallback used by nix/overlays.nix only while nixpkgs' openshell is older than
# 0.1.0 (it was 0.0.116 when this was written). Once nixpkgs reaches 0.1.0 or
# newer, the overlay picks nixpkgs' package and this file can be deleted.
#
# To bump: change `version`, then replace each hash with the SRI form of the
# matching line in
# https://github.com/NVIDIA/OpenShell/releases/download/v<version>/openshell-checksums-sha256.txt
# (`nix hash convert --hash-algo sha256 --from base16 --to sri <hex>`).
# The gateway container image tag follows `version` (hosts/desktop/openshell.nix).
let
  version = "0.1.9";
  sources = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-musl";
      hash = "sha256-OFase2suM9bIq3KhA2REFWUW5zA9qFqbE/ZhoqpjvS0=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-musl";
      hash = "sha256-y5I9CHA7lm9+DmsUg+1Lpu13vBCBLFUCvMH7buD2rVk=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-NVv2EhWeqgxTdfrNjydTbZy1TlrwMDKOqDmpJ6eQHaU=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "openshell: no upstream binary for ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "openshell";
  inherit version;

  src = fetchurl {
    url = "https://github.com/NVIDIA/OpenShell/releases/download/v${version}/openshell-${source.target}.tar.gz";
    inherit (source) hash;
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    bin=$(find . -type f -name openshell | head -n1)
    test -n "$bin" || { echo "openshell binary not found in the release tarball" >&2; exit 1; }
    install -Dm755 "$bin" $out/bin/openshell
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/NVIDIA/OpenShell/releases/tag/v${version}";
    description = "The safe, private runtime for autonomous AI agents";
    homepage = "https://docs.nvidia.com/openshell/index.html";
    license = lib.licenses.asl20;
    mainProgram = "openshell";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
