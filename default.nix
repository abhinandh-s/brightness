{
  pkgs ? import <nixpkgs> { },
}:
let
  rustPlatform = pkgs.rustPlatform;
  manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
in
rustPlatform.buildRustPackage rec {
  pname = manifest.name;
  version = manifest.version;
  cargoLock.lockFile = ./Cargo.lock;
  src = pkgs.lib.cleanSource ./.;

  buildInputs = with pkgs; [
    pkg-config
    libudev-zero
    libgudev
  ];

  nativeBuildInputs = with pkgs; [ pkg-config ];

  doCheck = false;

  meta = with pkgs.lib; {
    description = manifest.description;
    homepage = "https://github.com/abhi-xyz/brightness";
    changelog = "https://github.com/abhi-xyz/brightness/releases";
    license = licenses.mit;
    maintainers = with maintainers; [ abhi-xyz ];
    platforms = platforms.linux;
    mainProgram = manifest.name;
  };
}
