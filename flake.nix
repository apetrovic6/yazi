{
  description = "Wrapped Yazi configuration";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  # inputs.wrappers.url = "path:/home/apetrovic/clan/nix-wrapper-modules";
  inputs.wrappers.url = "github:apetrovic6/nix-wrapper-modules";
  inputs.wrappers.inputs.nixpkgs.follows = "nixpkgs";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    wrappers,
    treefmt-nix,
    ...
  } @ inputs: let
    forAllSystems = with nixpkgs.lib; genAttrs platforms.all;
    module = ./module.nix;
    yazi = wrappers.wrappers.yazi;

    treefmtEval = forAllSystems (system: treefmt-nix.lib.evalModule (import nixpkgs {inherit system;}) {programs.alejandra.enable = true;});
  in {
    formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
    wrappers.default = yazi;
    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        default = yazi.wrap {
          inherit pkgs;
          yazi = {
            mgr = {
              show_hidden = true;
            };
          };
        };
      }
    );
  };
}
