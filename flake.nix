{
  description = "Nix package for Bash Language Server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    formatter.${system} = pkgs.alejandra;
    packages.${system}.default = pkgs.bash-language-server;
    devShells.${system}.default = pkgs.mkShell {
      packages = [pkgs.bash-language-server pkgs.pnpm];
    };
  };
}
