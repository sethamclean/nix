{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "code2prompt";
  version = "3.0.2";

  src = pkgs.fetchurl {
    url =
      "https://github.com/mufeedvh/code2prompt/releases/download/v3.0.2/code2prompt-x86_64-unknown-linux-gnu";
    sha256 = "sha256-q1XG9dRWnp703RIXwlEAbKpyBkGXI4+I7nHcU5+KglU=";
  };

  # No need to unpack the binary
  dontUnpack = true;

  # Install the binary
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/code2prompt
    chmod +x $out/bin/code2prompt
  '';

  meta = with pkgs.lib; {
    description =
      "Generate prompts from your code for AI programming assistants like ChatGPT and Claude";
    homepage = "https://github.com/mufeedvh/code2prompt";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
