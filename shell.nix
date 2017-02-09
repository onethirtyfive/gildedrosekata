{ bootpkgs ? import <nixpkgs> {}
, ruby ? bootpkgs.ruby
, ...
}:
let
  # pinChannel down to specific version
  pkgs = import (bootpkgs.fetchzip (import ./z/etc/lib/version.nix)) {};
  inherit (pkgs) stdenv callPackage lib;

  appRoot = builtins.toPath ./.;
  bundlePath = builtins.toPath "${appRoot}/vendor";
  gildedrose = callPackage ./default.nix { };

  # TODO: tune for containerization
  isSource = path: type: (type == "directory" && builtins.baseNameOf path == "z");
    #(type != "directory" && builtins.baseNameOf path != ".git")
    #|| (type != "directory" && builtins.baseNameOf path != "log")
    #|| (type != "directory" && builtins.baseNameOf path != "tmp")
    #|| (type != "directory" && builtins.baseNameOf path != "snapshots");

in stdenv.mkDerivation {
  name = "gildedrose-devenv";
  src = builtins.filterSource isSource ./.;

  env = gildedrose;

  buildInputs = with pkgs; [
    ruby
    bundler
    bundix

    # libs needed for Ruby/C native extensions
    cmake
    libxml2
    libxslt
    pkgconfig
  ];

  shellHooks = ''
    mkdir -m 0700 -p "${bundlePath}"

    export GEM_HOME="${bundlePath}"
    export GEM_PATH="${gildedrose}/lib:${bundlePath}"
    bundle config --local path ${bundlePath}

    export ACKRC=".ackrc"

    alias be="bundle exec"
    alias bi="bundle install --path ${bundlePath}"
    alias spec="bundle exec rake 2>&1 | tee spec.log"

    if [ -f "${appRoot}/.env" ]; then
      source "${appRoot}/.env"
    else
      >&2 echo "Error: you do not have an .env file under: ${appRoot}"
    fi
  '';
}
