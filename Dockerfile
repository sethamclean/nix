FROM alpine:latest

# use the apline openssh package so that groups and default configs are created
# code spaces also has an easier time finding sshd then trying to point it to
# the nix store.
RUN apk update && apk add --no-cache curl openssh
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-confirm 
# We just needed curl to install nix, so we can remove it now
RUN apk del curl
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
RUN echo "auto-optimise-store = true" >> /etc/nix/nix.conf
ADD *.nix /root/nix/
ADD flake.lock /root/nix/
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
RUN cd /root/nix && nix profile install
ADD supervisord.conf /etc/supervisord.conf
CMD ["supervisord", "-c", "/etc/supervisord.conf"]
