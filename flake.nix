{
  description = "The root nix flake for Starling Cybernetics infrastructure";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane = {
      url = "github:ipetkov/crane";
      inputs = { nixpkgs.follows = "nixpkgs"; };
    };
  };

  outputs = inputs @ { self, nixpkgs, flake-parts, crane, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        with pkgs;
        let localPackages = callPackage ./packages ({ inherit pkgs crane; });
        in rec {
          packages = builtins.listToAttrs localPackages;
          devShells.default = callPackage ./shell.nix { inherit pkgs localPackages; };

          # Permits unfree licenses, thank you to <https://jamesconroyfinn.com/til/flake-parts-and-unfree-packages>
          _module.args.pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
    };
  };
}
