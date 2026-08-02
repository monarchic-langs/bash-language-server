{
  description = "Nix package for Bash Language Server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pname = "bash-language-server-source";
    version = "0.0.0";
    pnpmDeps = pkgs.pnpm_10.fetchDeps {
      inherit pname version;
      src = ./.;
      fetcherVersion = 4;
      hash = "sha256-DbxHvGJe6Jz4VwP5P8Sasgc+29F6akYKuz7ht8+BDdA=";
    };
    sourceCheck = name: command:
      pkgs.stdenv.mkDerivation {
        inherit pname version pnpmDeps;
        name = "bash-language-server-${name}";
        src = ./.;
        nativeBuildInputs = [
          pkgs.nodejs_22
          pkgs.bash-completion
          pkgs.coreutils
          pkgs.findutils
          pkgs.man-db
          pkgs.man-pages-posix
          pkgs.pkg-config
          pkgs.pnpm_10.configHook
          pkgs.shellcheck
          pkgs.shfmt
          pkgs.util-linux
        ];
        env.CI = "true";
        env.MANPATH = "${pkgs.man-pages-posix}/share/man";
        buildPhase = ''
          runHook preBuild
          ${command}
          runHook postBuild
        '';
        installPhase = ''
          touch "$out"
        '';
      };
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

        source-verify = sourceCheck "source-verify" "pnpm verify:bail";
      };
    };
    devShells = {
      ${system}.default = pkgs.mkShell {
        packages = [
          pkgs.bash-language-server
          pkgs.bash-completion
          pkgs.coreutils
          pkgs.findutils
          pkgs.man-db
          pkgs.man-pages-posix
          pkgs.nodejs_22
          pkgs.pkg-config
          pkgs.pnpm_10
          pkgs.shellcheck
          pkgs.shfmt
          pkgs.util-linux
        ];
        shellHook = ''
          export MANPATH="${pkgs.man-pages-posix}/share/man"
        '';
      };
    };
    apps = {
      ${system}.upgrade-tree-sitter = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "upgrade-tree-sitter";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
            pkgs.nodejs_22
            pkgs.pnpm_10
          ];
          text = ''
            exec ${pkgs.bash}/bin/bash scripts/upgrade-tree-sitter.sh
          '';
        }}/bin/upgrade-tree-sitter";
      };
    };
  };
}
