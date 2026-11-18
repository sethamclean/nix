{
  pkgs,
  userName,
  ...
}:
# OpenShell gateway as a rootless Podman container, run by a `seth` user service.
# Follows NVIDIA's rootless Podman instructions:
# https://docs.nvidia.com/openshell/how-it-works/gateways/container-deployment
# The gateway image tag follows the CLI version (nix/pkgs/openshell.nix), so the two stay matched.
let
  dataDir = "/home/${userName}/.local/share/openshell-gateway";
  image = "ghcr.io/nvidia/openshell/gateway:${pkgs.openshell.version}";
  userns = "--userns=keep-id:uid=1000,gid=1000";

  # Generate the mTLS bundle once; later starts reuse it.
  generateCerts = pkgs.writeShellScript "openshell-generate-certs" ''
    set -eu
    mkdir -p ${dataDir}
    if [ ! -f ${dataDir}/tls/ca.crt ]; then
      podman run --rm ${userns} \
        -v ${dataDir}:${dataDir} \
        -e HOME=${dataDir} \
        ${image} \
        generate-certs --output-dir ${dataDir}/tls
    fi
  '';
in
{
  # Rootless Podman only. No dockerCompat: rootless Docker owns the `docker` command.
  virtualisation.podman.enable = true;

  # The CLI must read the same TLS directory as the gateway.
  environment.sessionVariables.OPENSHELL_LOCAL_TLS_DIR = "${dataDir}/tls";

  systemd.user.services.openshell-gateway = {
    description = "OpenShell gateway (rootless Podman)";
    wantedBy = [ "default.target" ];
    requires = [ "podman.socket" ];
    after = [ "podman.socket" ];
    # newuidmap/newgidmap come from /run/wrappers; rootless Podman needs them.
    path = [
      pkgs.podman
      "/run/wrappers"
    ];
    serviceConfig = {
      # The first start pulls the image, which can take longer than the 90s default.
      TimeoutStartSec = "10min";
      Restart = "on-failure";
      RestartSec = "10s";
      ExecStartPre = generateCerts;
      ExecStart = ''
        ${pkgs.podman}/bin/podman run --rm --replace \
          --name openshell-gateway \
          ${userns} \
          -p 127.0.0.1:8080:8080 \
          -v ${dataDir}:${dataDir} \
          -v %t/podman/podman.sock:/var/run/podman.sock \
          -e HOME=${dataDir} \
          -e XDG_DATA_HOME=${dataDir} \
          -e OPENSHELL_LOCAL_TLS_DIR=${dataDir}/tls \
          -e OPENSHELL_COMPUTE_DRIVER=podman \
          -e OPENSHELL_PODMAN_SOCKET=/var/run/podman.sock \
          -e OPENSHELL_DB_URL=sqlite:${dataDir}/gateway.db \
          ${image}
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop --ignore openshell-gateway";
    };
  };
}
