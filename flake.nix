{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      version = "2026.10.23-53cde5e";
      hytale-launcher-zip = pkgs.fetchurl {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
        sha256 = "7df1351b38a6ae0bcf5d9a681c10911fe305a0ee708edf3f1323fb3242755c9e";
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
