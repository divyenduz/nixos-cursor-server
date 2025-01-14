{
  description = "NixOS VSCode server";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    {
      nixosModule = self.nixosModules.default; # Deprecrated, but perhaps still in use.
      nixosModules.default = import ./modules/cursor-server;
      nixosModules.home = self.homeModules.default; # Backwards compatiblity.
      homeModules.default = import ./modules/cursor-server/home.nix; # Consistent with homeConfigurations.
    }
    // (let
      inherit (flake-utils.lib) defaultSystems eachSystem;
    in
      eachSystem defaultSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.lib) hasSuffix optionalAttrs;
        auto-fix-cursor-server = pkgs.callPackage ./pkgs/auto-fix-cursor-server.nix { };
      in
        # The package depends on `inotify-tools` which is only available on Linux.
        optionalAttrs (hasSuffix "-linux" system) {
          packages = {
            inherit auto-fix-cursor-server;
            default = auto-fix-cursor-server;
          };
          checks = {
            inherit auto-fix-cursor-server;
          };
        }));
}
