{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "tfenv";
  version = "3.0.0";

  src = pkgs.fetchurl {
    url = "https://github.com/tfutils/tfenv/archive/refs/tags/v3.0.0.tar.gz";
    sha256 = "0j5nycyp9bhwv6xcqm0rzx1n6x5vm7xgsqjyz3xa67r1bbj34ca6";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin/
    chmod +x $out/bin/*
  '';

  meta = with pkgs.lib; {
    description = "Terraform version manager inspired by rbenv";
    homepage = "https://github.com/tfutils/tfenv";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
