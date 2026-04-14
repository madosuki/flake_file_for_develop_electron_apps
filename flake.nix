{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejsVersion = "v24.11.1";
        nodejsSrc = pkgs.fetchurl {
            url = "https://nodejs.org/dist/${nodejsVersion}/node-${nodejsVersion}-linux-x64.tar.xz";
            sha256 = "1a49h9dvl7gi136x7606vrvdg319ak18fd30r9552688a2lb1qv0";
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
          # utility
          git

          # libs for electron
          openssl
          glibc
          glibc.dev
          glib
          zlib
          alsa-lib
          dbus
          at-spi2-core
          libGL
          libX11
          libXext
          libXrandr
          libXcomposite
          libXdamage
          libXfixes
          libxcb
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
          gtk4

          # tyepscript
          typescript
          typescript-language-server

          # js runtime
          customNodejs
          bun

          # package manager
          pnpm

          # lint or format tool
          oxlint

          # shell
          bash
        ];
      in
        {

          devShells.default =
            (pkgs.buildFHSEnv {
              name = "electron-dev-fhs";
              targetPkgs = pkgs: devPackages;
              profile = ''
                # export PATH=${customNodejs}/bin:$PATH
                export PATH=$HOME/.npm_global/bin:$PATH

                npm config set prefix '~/.npm_global'
                # echo "Custom Node.js environment loaded (version: $(${customNodejs}/bin/node -v))"
              '';
              runScript = ''
              bash
              '';
            }).env;
        });
}
