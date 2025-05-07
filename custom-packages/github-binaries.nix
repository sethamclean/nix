{ pkgs }:

let
  # Function to create a mkDerivation for a GitHub binary release
  mkGitHubBinaryDerivation = { pname, version, filename, sha256, description
    , homepage, license ? pkgs.lib.licenses.mit }:
    pkgs.stdenv.mkDerivation {
      inherit pname version;

      src = pkgs.fetchurl {
        url =
          "https://github.com/${homepage}/releases/download/v${version}/${filename}";
        inherit sha256;
      };

      # No need to unpack the binary
      dontUnpack = true;

      # Install the binary
      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/${pname}
        chmod +x $out/bin/${pname}
      '';

      meta = with pkgs.lib; {
        inherit description homepage license;
        platforms = platforms.linux;
      };
    };
in {
  # Define the code2prompt package
  code2prompt = mkGitHubBinaryDerivation {
    pname = "code2prompt";
    version = "3.0.2";
    filename = "code2prompt-linux-amd64";
    sha256 = "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5";
    description =
      "Generate prompts from your code for AI programming assistants like ChatGPT and Claude";
    homepage = "mufeedvh/code2prompt";
  };

  # Add more GitHub binary packages as needed
  # example = mkGitHubBinaryDerivation { ... };
}
