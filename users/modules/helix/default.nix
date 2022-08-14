{
  inputs,
  pkgs,
  ...
}: {
  programs.helix = {
    enable = true;
    languages = [
      {
        name = "dockerfile";
        roots = ["Dockerfile" "Containerfile"];
        file-types = ["Dockerfile" "Containerfile" "dockerfile" "containerfile"];
      }
      {
        name = "nix";
        language-server = {command = "${inputs.nil.packages.${pkgs.system}.default}/bin/nil";};
      }
      {
        name = "rust";
        language-server = {command = "${pkgs.rust-analyzer}/bin/rust-analyzer";};
      }
    ];
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        middle-click-paste = false;
        true-color = true;
        whitespace.render = "all";
        cursor-shape.insert = "bar";
        lsp.display-messages = true;
        indent-guides = {
          render = true;
          character = "|";
        };
        auto-pairs = {
          "(" = ")";
          "{" = "}";
          "[" = "]";
          "\"" = "\"";
          "'" = "'";
          "<" = ">";
        };
      };
    };
    themes = {
      catppuccin_mocha = builtins.fromTOML (
        builtins.readFile (
          builtins.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/helix/47710cbb38a5462973a484283a749543914c73e9/italics/catppuccin_mocha.toml";
            sha256 = "sha256:1bv07mmi6hz7igd2pz7brcgs154989hnq8jmxy8px9d1jpx753di";
          }
        )
      );
    };
  };
}
