{
  description = "brightness";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        buildInputs = with pkgs; [
          pkg-config
          libudev-zero
          libgudev
        ];
      in
      {
        #        packages.brightness = 
        packages.default =
          let
            rustPlatform = pkgs.rustPlatform;
            manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
          in
          rustPlatform.buildRustPackage {
            pname = manifest.name;
            version = manifest.version;
            cargoLock.lockFile = ./Cargo.lock;
            src = pkgs.lib.cleanSource ./.;

            nativeBuildInputs = with pkgs; [ pkg-config ];

            buildInputs = buildInputs;

            doCheck = false;

            meta = with pkgs.lib; {
              mainProgram = manifest.name;
              description = manifest.description;
              homepage = "https://github.com/abhi-xyz/brightness";
              changelog = "https://github.com/abhi-xyz/brightness/releases";
              license = licenses.mit;
              maintainers = with maintainers; [ abhi-xyz ];
              platforms = platforms.linux;
            };
          };

        devShells.default = import ./shell.nix { inherit pkgs; };
      }
    );
}
