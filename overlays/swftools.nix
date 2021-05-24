final: prev: {
  swftools = prev.swftools.overrideAttrs (old: {
    meta = old.meta // {
      broken = false;
    };
  });
}
