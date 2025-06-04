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
RUN cat <<EOF > /etc/default/locale
# /etc/default/locale
LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
EOF
COPY . /root/nix/
RUN cd /root/nix && nix profile install
RUN mkdir -p /etc/searxng
COPY supervisord.conf /etc/supervisord.conf
COPY searxng-settings.yml /etc/searxng/settings.yml
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
