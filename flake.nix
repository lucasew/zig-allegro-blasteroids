{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    packages.${system} = rec {
      zig-allegro-blasteroids = import ./. {
        inherit pkgs;
      };
      default = zig-allegro-blasteroids;
    };
    devShells.${system} = rec {
      zig-allegro-blasteroids = import ./shell.nix {
        inherit pkgs;
      };
      default = zig-allegro-blasteroids;
    };
  };
}
