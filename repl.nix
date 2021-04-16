let
  sysFlake = builtins.getFlake (toString ./.);
  nixpkgs = import <nixpkgs> { };
in
{ inherit sysFlake; } // nixpkgs
