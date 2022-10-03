final: prev: {
  rofi-bluetooth-wayland =
    (prev.rofi-bluetooth.override {rofi-unwrapped = final.rofi-wayland-unwrapped;})
    .overrideAttrs (old: {
      src = final.fetchFromGitHub {
        owner = "nickclyde";
        repo = "rofi-bluetooth";
        rev = "0c07719c428984893c46f6cfe0a56660e03ccf50";
        sha256 = "sha256-Er59/fMhcA7xCXn3abMeBlrYfDYsOBApeykR1r8XbNU=";
      };
    });
}
