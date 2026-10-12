{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      version = "2026.10.09-4e41671";
      hytale-launcher-zip = pkgs.fetchurl {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
        sha256 = "ed52aacf6ca640bbe004b6eae699958eeedc5fc13eaf9120b58e3c324e5d9dff";
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
