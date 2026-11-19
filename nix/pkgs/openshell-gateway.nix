{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
# NVIDIA OpenShell gateway plus its microVM compute driver, from the upstream
# release binaries (glibc builds, patched to run on NixOS). The gateway starts
# `openshell-driver-vm` itself, so both must be on the gateway's PATH.
#
# Keep `version` equal to nix/pkgs/openshell.nix (the CLI); nix/overlays.nix asserts it.
# To bump: change `version`, then replace each hash with the SRI form of the matching
# line in https://github.com/NVIDIA/OpenShell/releases/download/v<version>/
# openshell-gateway-checksums-sha256.txt and openshell-checksums-sha256.txt
# (`nix hash convert --hash-algo sha256 --from base16 --to sri <hex>`).
let
  version = "0.1.9";
  sources = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      gatewayHash = "sha256-wyCF1kzO8DcSHA6HvuGlfW6IbXf3e7iyYMsI8KbM5qM="; # c32085d6…
      driverHash = "sha256-h70m5fSazcTGFlqkY605ZMQNXvBmEl+ZlW9+juoKD2U="; # 87bd26e5…
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu";
      gatewayHash = "sha256-pBcBwtx6wauhOw1IZ43LlQkAVapCohA7KucS+3kzixo="; # a41701c2…
      driverHash = "sha256-PUqVMpVQRyR3rR9cEIsQ3hlEkONATSJh5VViAaDS0z0="; # 3d4a9532…
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "openshell-gateway: no upstream gateway binary for ${stdenv.hostPlatform.system}");
  release = "https://github.com/NVIDIA/OpenShell/releases/download/v${version}";
in
stdenv.mkDerivation {
  pname = "openshell-gateway";
  inherit version;

  srcs = [
    (fetchurl {
      url = "${release}/openshell-gateway-${source.target}.tar.gz";
      hash = source.gatewayHash;
    })
    (fetchurl {
      url = "${release}/openshell-driver-vm-${source.target}.tar.gz";
      hash = source.driverHash;
    })
  ];
  sourceRoot = ".";

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 openshell-gateway $out/bin/openshell-gateway
    install -Dm755 openshell-driver-vm $out/bin/openshell-driver-vm
    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/NVIDIA/OpenShell/releases/tag/v${version}";
    description = "OpenShell gateway and microVM compute driver";
    homepage = "https://docs.nvidia.com/openshell/index.html";
    license = lib.licenses.asl20;
    mainProgram = "openshell-gateway";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
