{
  # Scaffold: Basic Golang Flakes
  description = "hello_flags";
  inputs.nixpkgs.url = "nixpkgs/nixos-23.11";
  inputs.nix2container.url = "github:nlewo/nix2container";

  outputs = { self, nixpkgs, nix2container }:
  let
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});

    version = "0.0.1";
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  in {
    packages = forAllSystems (
      system:
      let
        pkgs = nixpkgsFor.${system};
        nix2containerPkgs = nix2container.packages.${system};

        mkGoPkg = app_name: app_pkgs: pkgs.buildGoModule {
          inherit version;
          pname = app_name;
          src = pkgs.lib.sourceByRegex ./. [ "go.mod" "go.sum" "^(cmd).*" ];
          subPackages = if (builtins.length app_pkgs) > 0 then app_pkgs else [ "./..." ];

          CGO_ENABLED = 0;
          vendorHash = "sha256-4uKsbZYfeIlJKXXhAj6AgeyyHjeXPZWQ4IQmAVOkJe0=";
          meta = with pkgs.lib; {
            description = "Feature flags";
            homepage = "https://github.com/neonmei";
            license = licenses.agpl3;
            platforms = platforms.linux ++ platforms.darwin;
          };
        };

        mkGoCmd = app_name: mkGoPkg app_name ["cmd/${app_name}"];
        mkContainer = go_app: nix2containerPkgs.nix2container.buildImage {
          name = "${go_app.pname}";
          tag = "${go_app.version}";
          maxLayers = 50;

          contents = with pkgs; [ tzdata cacert ];
          config = {
            Entrypoint = ["${go_app}/bin/${go_app.pname}"];
            User = "65532:65532";
          };
        };

      in rec {
        hello_flags        = mkGoPkg "hello_flags" [];
        hello_boolean_app  = mkGoCmd "hello_boolean";
        hello_variants_app = mkGoCmd "hello_variants";

        hello_boolean_oci  = mkContainer hello_boolean_app;
        hello_variants_oci = mkContainer hello_boolean_app;
      }
    );

    defaultPackage = forAllSystems (system: self.packages.${system}.hello_flags);

    # Go development tools
    devShell = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            dive
            curl
            just
            gopls
            gotools
            skopeo
            mitmproxy
            toxiproxy
          ];
        }
    );
  };
}
