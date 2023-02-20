# An overlay of packages we want full control (not just overlays) of.
final: prev:
let
  inherit (final) callPackage;
in
{
  # Package template: x = final.callPackage ./x { };
  cfdyndns = callPackage ./cfdyndns.nix { };
  consul = callPackage ./consul.nix { };
}
