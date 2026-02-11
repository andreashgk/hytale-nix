{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      version = "2026.02.06-b95ae53";
      hytale-launcher-bin = pkgs.fetchzip {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
        sha256 = "sha256-FaBmlLUkMIW252gaLP4ixoP3HNNVnXe4x0YP/2jUf6M=";
      };
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
            openssl
            udev
            xorg.libX11
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
          ];

        runScript = "${hytale-launcher-bin}/hytale-launcher";
      };
    };
}
