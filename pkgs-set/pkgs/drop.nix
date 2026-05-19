{inputs, callPackage, ...}: callPackage "${inputs.drop}/nix" {
  modules = callPackage "${inputs.drop}/nix/modules.nix" {};
  webModules = callPackage "${inputs.drop}/nix/web-modules.nix" {};
} 
