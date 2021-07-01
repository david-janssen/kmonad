{
  description = "An advanced keyboard manager";

  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      pkg = import ./kmonad.nix;
      kmonad = pkgs.haskellPackages.callPackage pkg { };
    in {
      defaultPackage.x86_64-linux = kmonad;
      devShell.x86_64-linux = pkgs.haskellPackages.shellFor {
        packages = _: [ kmonad ];
        withHoogle = true;
        buildInputs = [ pkgs.haskellPackages.cabal-install ];
      };
      nixosModule = ({ ... }: {
        nixpkgs.overlays = [ self.overlay ];
        imports = [ ./module-base.nix ];
      });
      overlay = final: prev: { inherit kmonad; };
    };
}
