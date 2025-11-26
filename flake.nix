{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:

    # packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    # packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejsVersion = "v24.11.0";
        nodejsSrc = pkgs.fetchurl {
            url = "https://nodejs.org/dist/${nodejsVersion}/node-${nodejsVersion}-linux-x64.tar.xz";
            sha256 = "02ha1vqq4hq4jww1fiz3im3aybnb3rc4asd7zjj7pavki44rmnj6";
        };
        customNodejs = pkgs.stdenv.mkDerivation {
            inherit nodejsVersion;
            pname = "node-${nodejsVersion}-unofficial";
            version = nodejsVersion;

            src = nodejsSrc;

            unpackPhase = ''
                  tar xf $src

                  # get extracted directory
                  sourceRoot=$(find . -maxdepth 1 -type d -name "node-${nodejsVersion}-linux-x64")
                  echo "Source root is: $sourceRoot"
            '';

            installPhase = ''
              mkdir -p $out/bin $out/lib
              cp -r ./* $out/
            '';
          };

        devPackages = with pkgs; [
          openssl
          glibc
          glibc.dev
          glib
          zlib
          alsa-lib
          dbus
          at-spi2-core
          libGL
          xorg.libX11
          xorg.libXext
          xorg.libXrandr
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXfixes
          xorg.libxcb
          stdenv.cc.cc.lib
          cups.lib
          cups
          nssTools
          nss
          mesa
          libgbm
          udev
          libxkbcommon
          pango
          cairo
          nspr
          libdrm
          expat
          atk
          gtk3
          customNodejs
          bun
          zsh
        ];
      in
        {

          devShells.default =
            (pkgs.buildFHSEnv {
              name = "electron-dev-fhs";
              targetPkgs = pkgs: devPackages;
              profile = ''
                export PATH=${customNodejs}/bin:$PATH
                export PATH=$HOME/.npm_global/bin:$PATH
                npm config set prefix '~/.npm_global'
                echo "Custom Node.js environment loaded (version: $(${customNodejs}/bin/node -v))"
              '';
              runScript = ''
              zsh
              '';
            }).env;
        });
}
