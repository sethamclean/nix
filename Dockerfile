FROM alpine:latest

RUN apk update && apk add --no-cache openssh nix --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
RUN echo "experimental-features = nix-command flakes" > /etc/nix/nix.conf
RUN echo "auto-optimise-store = true" >> /etc/nix/nix.conf
ADD *.nix /root/nix/
ADD flake.lock /root/nix/
RUN cd /root/nix && nix build
CMD ["sh", "-c", "cd /root/nix && nix develop --command=zsh"]
