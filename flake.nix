{
  description = "A flake for Penumbra infrastructure software";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane = {
      url = "github:ipetkov/crane";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, crane, ... }:
    let util = import ./util.nix { inherit nixpkgs; }; in with util;
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.nixosModules = importAll ./modules self;
      flake.lib = { inherit util; };
      systems = [ "x86_64-linux" ];
      perSystem = { pkgs, ... }:
        with pkgs; with builtins; let
          nonDefault = packages:
            map (name: packages.${name})
              (filter (name: name != "default") (attrNames packages));
        in rec {
          devShells.default = mkShell { buildInputs = nonDefault packages; };
          packages = importAll ./packages { inherit pkgs crane; } // {
            default = symlinkJoin {
              name = "penumbra-default";
              paths = nonDefault packages;
            };
          };
        };
    };
}
