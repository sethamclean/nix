{ pkgs }:
pkgs.symlinkJoin {
  name = "browser-testing";
  paths = [ pkgs.playwright-test ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/playwright" \
      --set-default FONTCONFIG_FILE ${pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; }}
  '';
}
