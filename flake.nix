{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      version = "2026.11.16-1726018";
      hytale-launcher-zip = pkgs.fetchurl {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
        sha256 = "24341e50a9e3ee37ffcf68943bb924dc8d0af18071fa3fde55d2755a9add54fe";
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
