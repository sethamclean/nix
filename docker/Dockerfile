FROM ubuntu:24.04

ARG USERNAME=seth

RUN \
  apt-get update && \
  apt-get install -y curl sudo && \
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-confirm && \
  apt-get remove -y curl && \
  rm -rf /var/lib/apt/lists/*
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
RUN <<EOF
mkdir -p /etc/nix
cat <<EOI > /etc/nix/nix.conf
experimental-features = nix-command flakes 
auto-optimise-store = true
EOI
EOF
RUN cat <<EOF > /etc/default/locale
# /etc/default/locale
LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
EOF
RUN if ! id -u ${USERNAME} >/dev/null 2>&1; then useradd -m -s /bin/bash ${USERNAME}; fi
RUN groupadd --force docker && usermod -aG docker,sudo ${USERNAME}
RUN printf '%s ALL=(ALL) NOPASSWD:ALL\n' "${USERNAME}" > /etc/sudoers.d/${USERNAME} && chmod 0440 /etc/sudoers.d/${USERNAME}
RUN mkdir -p /home/${USERNAME}/ws /workspaces && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/ws
COPY flake.nix flake.lock /home/${USERNAME}/ws/nix/
COPY nix /home/${USERNAME}/ws/nix/nix/
RUN mkdir -p /nix/var/nix/profiles/per-user/root
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && cd /home/${USERNAME}/ws/nix && nix profile add --no-update-lock-file --profile /nix/var/nix/profiles/per-user/root/profile .#codespace-daemons
RUN mkdir -p /nix/var/nix/profiles/per-user/${USERNAME} && chown -R ${USERNAME}:${USERNAME} /nix/var/nix/profiles/per-user/${USERNAME}
RUN . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh && cd /home/${USERNAME}/ws/nix && nix profile add --no-update-lock-file --profile /nix/var/nix/profiles/per-user/${USERNAME}/profile .#default
# For fresh-codespace DinD testing, prefer overlay2 by default.
# If this fails in a given runtime, switch back to vfs.
RUN <<EOF
mkdir -p /etc/docker
cat <<EOI > /etc/docker/daemon.json
{
  "storage-driver": "overlay2"
}
EOI
EOF
RUN mkdir -p /etc/searxng
RUN mkdir -p /etc/wezterm
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/searxng-settings.yml /etc/searxng/settings.yml
RUN rm -rf /home/${USERNAME}/ws && ln -s /workspaces /home/${USERNAME}/ws && chown -h ${USERNAME}:${USERNAME} /home/${USERNAME}/ws
ENV PATH="/nix/var/nix/profiles/per-user/root/profile/bin:/nix/var/nix/profiles/default/bin:${PATH}"
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
