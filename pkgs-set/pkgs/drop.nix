{inputs, callPackage, ...}: callPackage "${inputs.drop}/nix" {
  modules = (callPackage "${inputs.drop}/nix/modules.nix" {}).overrideAttrs (old: {
    outputHash = "sha256-Pm3vl9Uqnqi375ewDNsVlr6a9AJiuNKq/VwFmYsliJA=";
  });
} 
