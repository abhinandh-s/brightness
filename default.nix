{
  pkgs ? import <nixpkgs> { },
}:
let
  rustPlatform = pkgs.rustPlatform;
  manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
in
rustPlatform.buildRustPackage {
  pname = manifest.name;
  version = manifest.version;
  cargoLock.lockFile = ./Cargo.lock;
  src = pkgs.lib.cleanSource ./.;

  buildInputs = with pkgs; [
    pkg-config
    llvmPackages.bintools
    libudev-zero
    libgudev
  ];

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
}
