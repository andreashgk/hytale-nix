{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      version = "2026.01.29-06d8678";
      hytale-launcher-bin = pkgs.fetchzip {
        url = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-${version}.zip";
        sha256 = "sha256-NGf2hb7wcuiOKYu7Ub2Dv8lor2wm/mHRleilkKu3yOU=";
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
