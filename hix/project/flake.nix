{
  description = "Default hix flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.src.flake = false;
  outputs = { self, src, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-darwin" ] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          hixProject =
            final.haskell-nix.hix.project {
              inherit src;
            };
        })
        (final: prev: {
          evalPackages = import final.path {
            # If we are building a flake there will be no currentSystem attribute
            system = "x86_64-darwin";
            overlays = [ haskellNix.overlay ];
          };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.hixProject.flake {};
    in flake // {
      legacyPackages = pkgs;
    });
}
