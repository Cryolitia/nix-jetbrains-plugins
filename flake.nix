{
  description = "
    `JetBrains plugins as `Nix` expressions.
    Learn more in the flake [repo](https://github.com/nix-community/https://github.com/Cryolitia/nix-jetbrains-plugins).
  ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      inherit (nixpkgs) lib;
    in
    {
      default = import ./plugins.nix { inherit lib; };
    };
}
