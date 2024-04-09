# Nix plugins for JetBrains IDEs

Daily update by Github action, auto fail back to [nixpkgs's plugins](https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/jetbrains/plugins/plugins.json).

## Usage (with flakes)

```nix
{
  inputs =
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

      jetbrains-plugins = {
        url = "github:Cryolitia/nix-jetbrains-plugins/c125e6df5ff612595aeeba6ffafe5b474843c65d";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs =
    inputs: {
        nixosConfigurations = {
          [your-couputer] = inputs.nixpkgs.lib.nixosSystem rec {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs;
            };

            modules = (with inputs; [
              ./hosts/[your computer]
            ]);
          };
        };
    };
}
```

```nix
{ pkgs, inputs, ...}:
let
  common-plugins = [
    "github-copilot"
    "statistic"
    "chinese-simplified-language-pack----"
  ];
  addPlugins = (inputs.jetbrains-plugins.import pkgs).addPlugins;
  idea-ultimate = addPlugins pkgs.jetbrains.idea-ultimate common-plugins;
in {
  environment.systemPackages = [
    idea-ultimate
  ];
}
```

## Add new plugin

Edit `data/plugins.json`
