# {
#   flattenToml = import ./flattenToml.nix;
#   colorPicker = import ./colorPicker.nix;
#   music-manager = import ./music-manager.nix;
# }

lib:
lib // {
  estera = {
    flattenToml = import ./flattenToml.nix lib;
    colorPicker = import ./colorPicker.nix;
    music-manager = import ./music-manager.nix;

    colorScheme = import ../assets/theme.nix;
  };
}
