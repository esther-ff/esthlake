{ pkgs, ... }:

{
  systemd.services.bigeonBot = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    description = "shit bridge bot";

    serviceConfig = {
      Type = "simple";
      User = "esther";

      WorkingDirectory = "/data/git/uuhbot";
      ExecStart = ''${pkgs.nodejs}/bin/node /data/git/uuhbot/main.js'';
      Restart = "on-failure";

      KillMode = "process";
    };
  };
}
