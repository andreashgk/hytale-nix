{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      version = "2026.10.14-4344467";
      hytale-launcher-zip = pkgs.fetchurl {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
        sha256 = "b10863302c2125bcd099810a5d50f86e44ea46b2b44d1388f0768961d3b932f8";
      };
      # The zip is prefixed with a signed update header that `unzip` rejects, bsdtar skips it.
      hytale-launcher-bin = pkgs.runCommand "hytale-launcher-bin-${version}" {
        nativeBuildInputs = [ pkgs.libarchive ];
      } ''
        mkdir -p $out
        bsdtar -xf ${hytale-launcher-zip} -C $out
      '';
    in
    {
      packages.x86_64-linux.default = self.packages.x86_64-linux.hytale-launcher;

      packages.x86_64-linux.hytale-launcher = pkgs.buildFHSEnv {
        pname = "hytale-launcher";
        inherit version;

        targetPkgs =
          p: with p; [
            # Launcher
            libsoup_3
            gdk-pixbuf
            glib
            gtk3
            webkitgtk_4_1

            # Game
            alsa-lib
            icu
            libGL
            libX11
            libXcursor
            libXrandr
            libXi
            openssl
            udev
          ];

        runScript = "${hytale-launcher-bin}/hytale-launcher";
      };
    };
}
