{ ... }:

{
  nixpkgs.overlays = [ (final: prev: import ./default.nix) ];
  imports = [ ./module-base.nix ];
}
