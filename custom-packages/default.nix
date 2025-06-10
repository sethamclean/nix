{ pkgs }:

{
  # Import all custom packages
  code2prompt = import ./code2prompt.nix { inherit pkgs; };
  tfenv = import ./tfenv.nix { inherit pkgs; };

  # Add more custom packages here as needed
}
