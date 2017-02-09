{ lib, bundlerEnv, stdenv, ruby, openssl, which, pkgconfig }:
bundlerEnv {
  inherit ruby;

  name = "gildedrose-1.0";
  gemfile   = ./Gemfile;
  lockfile  = ./Gemfile.lock;
  gemset    = ./gemset.nix;
  meta = with lib; {
    description = "Gilded Rose Kata";
    license = licenses.mit;
    platforms = platforms.unix;
  };

  gemConfig = {
  };
}
