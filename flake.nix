{
  description = "Nix package for Bash Language Server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    formatter = {
      ${system} = pkgs.alejandra;
    };
    packages = {
      ${system}.default = pkgs.bash-language-server;
    };
    checks = {
      ${system} = {
        default = pkgs.bash-language-server;

        flake-format =
          pkgs.runCommand "bash-language-server-flake-format-check"
          {nativeBuildInputs = [pkgs.alejandra];}
          ''
            alejandra --check ${./flake.nix}
            touch $out
          '';

        bash-language-server-version =
          pkgs.runCommand "bash-language-server-version-check"
          {nativeBuildInputs = [pkgs.bash-language-server];}
          ''
            bash-language-server --version
            touch $out
          '';
      };
    };
    devShells = {
      ${system}.default = pkgs.mkShell {
        packages = [pkgs.bash-language-server pkgs.pnpm];
      };
    };
  };
}
