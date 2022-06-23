{
  description = "Default hix flake";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.src.flake = false;
  outputs = { self, src, nixpkgs, flake-utils, haskellNix }:
    flake-utils.lib.eachSystem [ "x86_64-darwin" "x86_64-linux" "aarch64-darwin" "aarch64-linux"] (system:
    let
      overlays = [ haskellNix.overlay
        (final: prev: {
          hixProject =
            final.haskell-nix.hix.project {
              inherit src;
            };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
      flake = pkgs.hixProject.flake {};
    in flake // {
      legacyPackages = pkgs;
    });
}
