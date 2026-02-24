# When this dir is used as a path (e.g. import), expose legacyPackages for the given system.
{ system ? builtins.currentSystem }:
let
  self = builtins.getFlake (toString ./.);
in
self.legacyPackages.${system}
