{ pkgs, ... }:

{
  systemd.services.bigeonBot = {
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    description = "Hehe bridge bot :3";

    serviceConfig = {
      Type = "simple";
      User = "esther";

      WorkingDirectory = "/data/git/uuhbot";
      #ExecStart = ''${pkgs.bun}/bin/bun run /data/git/uuhbot/main.ts'';
      ExecStart = '''';
      Restart = "on-failure";

      KillMode = "process";
    };
  };
}
