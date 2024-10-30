{
  description = "brightness"; # A brief description of your flake

  # Define the inputs for the flake, here we use flake-utils from GitHub
  inputs.flake-utils.url = "github:numtide/flake-utils";

  # The outputs of the flake, including self, nixpkgs, and flake-utils
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        # Access legacy packages for the current system
        pkgs = nixpkgs.legacyPackages.${system};

        # Define build inputs for your project
        buildInputs = with pkgs; [
          pkg-config # Tool to manage library compile and link flags
          libudev-zero # A library for device management
          libgudev # Another library for device handling
        ];

        # Define the default package to build for the current system
        defaultPackage =
          let
            rustPlatform = pkgs.rustPlatform; # Get Rust platform specifics
            manifest = (pkgs.lib.importTOML ./Cargo.toml).package; # Import the package metadata from Cargo.toml
          in
          rustPlatform.buildRustPackage {
            pname = manifest.name; # Package name
            version = manifest.version; # Package version
            cargoLock.lockFile = ./Cargo.lock; # Path to Cargo.lock for dependencies
            src = pkgs.lib.cleanSource ./.; # Source directory for the Rust package

            # Native build inputs specific to the Rust build environment
            nativeBuildInputs = with pkgs; [ pkg-config ];

            # Additional build inputs defined earlier
            buildInputs = buildInputs;

            doCheck = false; # Disable tests during the build process

            # Metadata for the package
            meta = with pkgs.lib; {
              mainProgram = manifest.name; # Specify the main program
              description = manifest.description; # Package description
              homepage = "https://github.com/abhi-xyz/brightness"; # Homepage of the project
              changelog = "https://github.com/abhi-xyz/brightness/releases"; # Changelog URL
              license = licenses.mit; # License type
              maintainers = with maintainers; [ abhi-xyz ]; # Maintainer information
              platforms = platforms.linux; # Supported platforms
            };
          };

      in
      {
        # Provide the packages output for the current system
        packages.default = defaultPackage; # Define the default package for this system

        # Define Home Manager modules for configuring the Otter program
        homeManagerModules.otter =
          {
            config,
            pkgs,
            lib,
            ...
          }:
          {
            # Options for the Otter program configuration
            options.program.otter = {
              enable = lib.mkEnableOption "Enable the Otter program"; # Option to enable or disable Otter

              package = lib.mkOption {
                type = lib.types.package; # Specify the type of this option
                default = defaultPackage; # Use the defined default package
                description = "The otter package to use."; # Description of the package option
              };
            };

            # Development shell configuration
            devShells.default = import ./shell.nix { inherit pkgs; }; # Import a shell.nix file for development environment
          };
      }
    ); # Ensure this closing parenthesis matches the opening one above
}
