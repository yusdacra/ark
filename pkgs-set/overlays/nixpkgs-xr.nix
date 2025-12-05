{inputs, ...}: final: prev:
((import inputs.nixpkgs-xr).overlays.default final prev)
// { wivrn = prev.wivrn; }
