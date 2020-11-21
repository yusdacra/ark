final: prev: {
  hikari = prev.hikari.overrideAttrs (old: rec { version = "2.2.2"; });
}
