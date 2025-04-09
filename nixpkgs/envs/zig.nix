with import (fetchTarball {
  url =
    "https://github.com/NixOS/nixpkgs/archive/eb0e0f21f15c559d2ac7633dc81d079d1caf5f5f.tar.gz";
}) { };

let
  zig = stdenv.mkDerivation {
    name = "zig";

    dontConfigure = true;
    dontBuild = true;
    dontFixup = true;

    src = fetchTarball
      "https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz";

    installPhase = ''
      mkdir -p $out/{doc,bin,lib}
        [ -d docs ] && cp -r docs/* $out/doc
        [ -d doc ] && cp -r doc/* $out/doc
        cp -r lib/* $out/lib
        cp zig $out/bin/zig

        PATH="$PATH:$out/bin"
    '';

  };
in mkShell { nativeBuildInputs = [ zig ]; }
