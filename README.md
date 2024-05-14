# hello_flags

The purpose of this app is taking [OpenFeature](https://openfeature.dev/) for a spin with minimal examples.

## Usage

If you have nix, you should be good to go. Make sure to have direnv + nix addon. If you perform `direnv allow` on this repo you will get all toolchain packages declared in `flake.nix` autoinstalled.

```bash
# run each app individually
nix run .#hello_boolean_app
nix run .#hello_variants_app

# this builds all apps:
nix build

# build minimal containers (use copyToDockerDaemon instead if using docker)
nix run .#hello_boolean_oci.copyToPodman
nix run .#hello_variants_oci.copyToPodman
```

Otherwise you might need a recent Golang / Docker environment and install tools manually using your distributions package manager.

