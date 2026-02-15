{
  inputs = {
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      naersk,
    }:
    let
      everySystem = attr: builtins.foldl' (accum: elem: accum // { ${elem} = (attr elem); }) { };
    in
    {
      packages = everySystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          naersk' = pkgs.callPackage naersk { };
        in
        {
          default = naersk'.buildPackage {
            src = pkgs.fetchFromGitHub {
              owner = "JakeStanger";
              repo = "ironbar";
              hash = "sha256-kSIy+WSKodVW81VevZcyCPu5qBsyBsBdFrj3KYvr2BQ=";
              rev = "master";
            };
            release = true;
            nativeBuildInputs = with pkgs; [
              openssl
              pkg-config
              dbus
              glib
              cairo
              graphene
              gtk4
              libevdev
              luajit
              gtk4-layer-shell
              udev
              libinput
              pulseaudio
            ];
            postInstall = ''
              mv $out/bin/ironbar $out/bin/.ironbar-wrapped
              echo "$out/bin/.ironbar-wrapped --config ${../../assets/config.corn} --theme ${../../assets/style.css}" > $out/bin/ironbar
              chmod +x $out/bin/ironbar
            '';
          };
        }
      ) [ "x86_64-linux" ];
    };
}
