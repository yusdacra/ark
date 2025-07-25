{ callPackage, inputs, ... }:
(callPackage "${inputs.gomod2nix}/builder" {
  gomod2nix = null;
}).buildGoApplication
