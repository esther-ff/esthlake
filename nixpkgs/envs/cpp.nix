{
  description = "cpp dev";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  system = "x86_64-linux";

  outputs = { nixpkgs, utils, ... }@inputs:
  let 
    pkgs = import nixpkgs { inherit system; };
    llvm = pkgs.llvmPackages_latest;
  in 
  {
    devShell = pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } rec {
      packages = with pkgs; [
        llvm.lldb
        gdb

        clang-tools

        llvm.libstdcxxClang

        valgrind
      ];
    };
    name = "cpp";
  }
}
