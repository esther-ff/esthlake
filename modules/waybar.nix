{ config, lib, ... }:
let
  inherit (lib.estera) colorPicker;
  inherit (lib.options) mkEnableOption;
  inherit (config.estera.flake.system) user;

  colorScheme = import ../assets/theme.nix;
  cfg = config.estera.programs.waybar;
in {
  options.estera.programs.waybar = { enable = mkEnableOption "waybar"; };

  config = lib.modules.mkIf cfg.enable {
    home-manager.users.${user} = {
      programs.waybar = {
        enable = true;
        style = ''
                 * {
                  font-family: "Fira Code";
                  font-size: 12px;
                }

                #cpu, #memory, #clock
                {
                  color: ${colorScheme.bg};
                  background-color: ${colorPicker 1};
                  padding: 0 3px;
                  margin-bottom: 4px;
                  /* border: 1px solid #140e07; */
                }

                #waybar {
                  background-color: ${colorScheme.bg};
                  color: ${colorScheme.fg};
                }

                window#waybar {
                  padding: 5px;
                  border-bottom: 2px solid ${colorPicker 1};
                }

                #tray {
                  background-color: ${colorScheme.fg};
                  color: ${colorPicker 1};
                }

                #workspaces {
                  background-color: ${colorPicker 1};
                  color: #140e07;
                          margin-bottom: 4px;

                  /* border: 2px solid #140e07; */
                }

                #workspaces button.active { background-color:  ${
                  colorPicker 1
                }; }
                #workspaces button.focused {
                      background-color: ${colorPicker 2};
                      /* box-shadow: inset 0 -3px #b586e8; */
                 }
                #workspaces button.urgent { background-color:  ${
                  colorPicker 3
                }; }

          button {
            padding: 0px;
            background-color: transparent;
            box-shadow: inset 0 -3px transparent;
            border: none;
            border-radius: 0;
          }

        '';

        settings = [{
          position = "top";
          mod = "dock";
          exclusive = true;
          passthrough = false;
          height = 20;
          spacing = 2;
          gtk-layer-shell = true;

          modules-left = [ "niri/workspaces" ];
          modules-right = [ "cpu" "memory" "clock" ];

          "niri/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            warp-on-scroll = false;
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              # "active" = "";
              # "default" = "";
            };
            persistent-workspaces = { "*" = 6; };
          };

          # tray = { spacing = 10; };

          clock = {
            tooltip-format = ''
              <big>{:%Y %B}</big>
              <tt><small>{calendar}</small></tt>'';
            format-alt = "{:%Y-%m-%d}";
          };

          cpu = {
            format = "cpu: {usage}%";
            tooltip = false;
          };

          memory = { format = "mem: {}%"; };

          temperature = {
            critical-threshold = 80;
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" "" "" ];
          };

          # network = {
          #   format-ethernet = "{ipaddr}/{cidr} ";
          #   tooltip-format = "{ifname} via {gwaddr} ";
          #   format-linked = "{ifname} (No IP) ";
          #   format-disconnected = "Disconnected ⚠";
          #   format-alt = "{ifname}: {ipaddr}/{cidr}";
          # };

          # pulseaudio = {
          #   format = "{volume}% {icon} {format_source}";
          #   format-bluetooth = "{volume}% {icon} {format_source}";
          #   format-bluetooth-muted = " {icon} {format_source}";
          #   format-muted = " {format_source}";
          #   format-source = "{volume}% ";
          #   format-source-muted = "";
          #   format-icons = {
          #     headphone = "";
          #     hands-free = "";
          #     headset = "";
          #     phone = "";
          #     portable = "";
          #     car = "";
          #     default = [ "" "" "" ];
          #   };
          #   on-click = "pavucontrol";
          # };
        }];
      };
    };
  };
}
