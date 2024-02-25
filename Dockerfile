FROM ubuntu:latest

RUN \
  apt-get update && \
  apt-get install -y curl && \
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
COPY flake.nix packages.nix flake.lock /root/nix/
RUN cd /root/nix && nix profile install
COPY supervisord.conf /etc/supervisord.conf
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
