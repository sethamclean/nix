{
  lib,
  writeShellApplication,
  openshell,
  stdenvNoCC,
}:
# `box`: stand up and use the development microVM sandbox.
# The VM size comes from the gateway config (hosts/desktop/openshell.nix), not from here:
# the VM driver ignores `--cpu` and `--memory`.
let
  dotfilesRepo = "https://github.com/sethamclean/dotfiles.git";
  policy = stdenvNoCC.mkDerivation {
    name = "box-policy.yaml";
    src = ../../openshell/policy.yaml;
    dontUnpack = true;
    installPhase = "cp $src $out";
  };
in
writeShellApplication {
  name = "box";
  runtimeInputs = [ openshell ];
  text = ''
    # The active gateway in ~/.config/openshell can be any registered one; box uses `local`.
    export OPENSHELL_GATEWAY=''${OPENSHELL_GATEWAY:-local}
    name=''${BOX_NAME:-dev}
    image=''${BOX_IMAGE:-ghcr.io/sethamclean/seth-docker:latest}

    usage() {
      echo "usage: box up | sh | recycle | rm | ls" >&2
      echo "  up       create the '$name' sandbox from $image and open a shell" >&2
      echo "  sh       open a shell in the running sandbox" >&2
      echo "  recycle  stop and start the sandbox (frees the VM's host memory, keeps its disk)" >&2
      echo "  rm       delete the sandbox" >&2
      echo "  ls       list sandboxes" >&2
      echo "env: BOX_NAME (default dev), BOX_IMAGE" >&2
      exit 2
    }

    # The sandbox's main process is `sleep infinity`: a sandbox ends when its main process
    # exits, and `box sh` cannot attach to a finished one. HOME and PATH are set as sandbox
    # environment because the supervisor otherwise uses HOME=/sandbox and no per-user Nix profile.
    sandbox_path=/nix/var/nix/profiles/per-user/seth/profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:/usr/bin:/bin

    # This runs in the sandbox, so $HOME must not expand here.
    # shellcheck disable=SC2016
    bootstrap='cd "$HOME"
      [ -d dotfiles ] || git clone --depth 1 ${dotfilesRepo} dotfiles
      cd dotfiles && ./bootstrap.sh'

    cmd=''${1:-}
    [ -n "$cmd" ] && shift
    case "$cmd" in
      up)
        echo "box: $name from $image" >&2
        openshell sandbox create --name "$name" --from "$image" --policy ${policy} \
          --detach --restart-policy always \
          --env HOME=/home/seth --env "PATH=$sandbox_path" \
          --env LANG=en_US.UTF-8 --env LC_ALL=en_US.UTF-8 "$@" -- /usr/bin/sleep infinity
        # Dotfiles are cloned once (policy: github egress). Re-run `box up` after `box rm`.
        openshell sandbox exec "$name" -- sh -c "$bootstrap"
        ;;
      # `sandbox connect` attaches to the main process (`sleep infinity`), not to a shell, so
      # open a login shell with `exec`. Closing it leaves the sandbox running.
      # `sandbox connect` attaches to the main process, so open a login shell with `exec`. The
      # dotfiles' ~/.profile then starts zsh, in /sandbox, with the environment `box up` set.
      sh) exec openshell sandbox exec "$name" --tty "$@" -- /usr/bin/bash -l ;;
      recycle)
        openshell sandbox stop "$name"
        openshell sandbox start "$name"
        ;;
      rm) exec openshell sandbox delete "$name" ;;
      ls) exec openshell sandbox list ;;
      *) usage ;;
    esac
  '';

  meta = {
    description = "Stand up the OpenShell development microVM";
    mainProgram = "box";
    platforms = lib.platforms.unix;
  };
}
