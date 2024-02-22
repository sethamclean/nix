FROM alpine:latest

RUN apk update && apk add --no-cache curl supervisor docker openssh
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-confirm 
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
RUN echo "auto-optimise-store = true" >> /etc/nix/nix.conf
ADD *.nix /root/nix/
ADD flake.lock /root/nix/
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"
RUN cd /root/nix && nix build
ADD supervisord.conf /etc/supervisord.conf
CMD ["sh", "-c", "cd /root/nix && nix develop --command supervisord -c /etc/supervisord.conf"]
