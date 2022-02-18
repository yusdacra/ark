{ format ? false }:
let
  inherit (builtins) isAttrs isList map;
  fmt =
    if format
    then "\n  "
    else "";
  mapAttrsToList = f: attrs: map (name: f name attrs.${name}) (builtins.attrNames attrs);
  concatStrings = builtins.concatStringsSep "";
  evalAttrs = attrs: concatStrings (mapAttrsToList (name: value: " ${name}=\"${value}\"") attrs);
  genAttrs = f: names:
    builtins.listToAttrs (map
    (n: {
      name = n;
      value = (f n);
    })
    names);
  evalChildren = children:
    if isList children
    then concatStrings children
    else children;
  tag =
    name: maybeAttrs:
      if isAttrs maybeAttrs
      then (children: "<${name}${evalAttrs maybeAttrs}>${fmt}${evalChildren children}${fmt}</${name}>")
      else tag name {} maybeAttrs;
  tags = (genAttrs tag ["html" "head" "body" "div" "p" "a"]);
in
  tags
  // {
    inherit tag;
    link = url: tags.a { href = url; };
  }
