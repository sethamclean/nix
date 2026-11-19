{
  pkgs,
  userName,
  ...
}:
# OpenShell gateway with the microVM compute driver, run by a `seth` user service.
# Each sandbox is its own libkrun microVM. The driver sizes every VM from the gateway
# config below; the CLI's `--cpu` and `--memory` flags are ignored by it.
# The gateway and driver come from nix/pkgs/openshell-gateway.nix (upstream binaries).
let
  dataDir = "/home/${userName}/.local/share/openshell-gateway";

  # 20 GiB of 32 GB leaves the desktop about 10 GiB. Guest memory is allocated on demand,
  # but the guest keeps its page cache, so this is also the worst case for the host.
  gatewayConfig = (pkgs.formats.toml { }).generate "openshell-gateway.toml" {
    openshell = {
      version = 2;
      gateway.compute_driver = "vm";
      drivers.vm = {
        vcpus = 12;
        mem_mib = 20480;
        overlay_disk_mib = 65536;
      };
    };
  };

  # Generate the mTLS bundle once; later starts reuse it. The CLI reads the same directory.
  generateCerts = pkgs.writeShellScript "openshell-generate-certs" ''
    set -eu
    mkdir -p ${dataDir}
    if [ ! -f ${dataDir}/tls/ca.crt ]; then
      ${pkgs.openshell-gateway}/bin/openshell-gateway generate-certs --output-dir ${dataDir}/tls
    fi
  '';
in
{
  # glibc binaries (the gateway's driver extracts a supervisor at run time) need nix-ld:
  # see programs.nix-ld in ./default.nix.
  environment.sessionVariables.OPENSHELL_LOCAL_TLS_DIR = "${dataDir}/tls";

  systemd.user.services.openshell-gateway = {
    description = "OpenShell gateway (microVM driver)";
    wantedBy = [ "default.target" ];
    # `openshell-driver-vm` is looked up on PATH; the driver builds ext4 images with e2fsprogs.
    path = [
      pkgs.openshell-gateway
      pkgs.e2fsprogs
    ];
    environment = {
      OPENSHELL_GATEWAY_CONFIG = "${gatewayConfig}";
      OPENSHELL_LOCAL_TLS_DIR = "${dataDir}/tls";
      OPENSHELL_SERVER_PORT = "8080";
      OPENSHELL_DB_URL = "sqlite:${dataDir}/gateway-vm.db";
    };
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "10s";
      ExecStartPre = generateCerts;
      ExecStart = "${pkgs.openshell-gateway}/bin/openshell-gateway";
    };
  };
}
