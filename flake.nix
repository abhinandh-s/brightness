{
  description = "brightness";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = nixpkgs.legacyPackages;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      homeManagerModules.brightness =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
        in
        {
          options.program.brightness = {
            enable = lib.mkEnableOption "Enable the brightness program";

            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.callPackage ./default.nix { };
              description = "The brightness package to use.";
            };
          };

          config = lib.mkIf config.program.brightness.enable {
            home.packages = [ config.program.brightness.package ];
          };
        };

      homeManagerModules.default = self.homeManagerModules.brightness;
      homeManagerModule.default = self.homeManagerModules.brightness;
      #
      packages = forAllSystems (system: {
        default = pkgsFor.${system}.callPackage ./default.nix { };
      });
      devShells = forAllSystems (system: {
        default = pkgsFor.${system}.callPackage ./shell.nix { };
      });
    };
}
