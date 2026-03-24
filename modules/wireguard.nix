{ pkgs, ... }:

{
  networking.wg-quick.interfaces =
    let
      keys = {
        priv = "/run/secrets/mullvad_private_key";
        pub = "uUYbYGKoA6UBh1hfkAz5tAWFv4SmteYC9kWh7/K6Ah0=";
      };
      serverIp = "92.60.40.209";
      listenPort = 51820;
      networkToBlock = "192.168.0.0/24";

      publicKey = keys.pub;
      privateKeyFile = keys.priv;
    in
    {
      wg0 = {
        address = [
          "10.72.48.149/32"
          "fc00:bbbb:bbbb:bb01::9:3094/128"
        ];

        dns = [ "10.64.0.1" ];
        inherit listenPort;
        inherit privateKeyFile;

        postUp = ''
          # Mark packets on the wg0 interface
          wg set wg0 fwmark 51820

          for ip in $(${pkgs.dig} +short mc.hypixel.net); do
              ${pkgs.iptables}/bin/iptables -I OUTPUT 1 -d $ip -p tcp --dport 25565 -j ACCEPT
          done

          # Forbid anything else which doesn't go through wireguard VPN on
          # ipV4 and ipV6
          ${pkgs.iptables}/bin/iptables -A OUTPUT \
            ! -d ${networkToBlock} \
            ! -o wg0 \
            -m mark ! --mark $(wg show wg0 fwmark) \
            -m addrtype ! --dst-type LOCAL \
            -j REJECT

          ${pkgs.iptables}/bin/ip6tables -A OUTPUT \
            ! -o wg0 \
            -m mark ! --mark $(wg show wg0 fwmark) \
            -m addrtype ! --dst-type LOCAL \
            -j REJECT
        '';

        postDown = "";
        # postDown = ''
        #   ${pkgs.iptables}/bin/iptables -D OUTPUT \
        #     ! -o wg0 \
        #     -m mark ! --mark $(wg show wg0 fwmark) \
        #     -m addrtype ! --dst-type LOCAL \
        #     -j REJECT
        #   ${pkgs.iptables}/bin/ip6tables -D OUTPUT \
        #     ! -o wg0 -m mark \
        #     ! --mark $(wg show wg0 fwmark) \
        #     -m addrtype ! --dst-type LOCAL \
        #     -j REJECT
        # '';
        peers = [
          {
            inherit publicKey;
            allowedIPs = [ "0.0.0.0/0" ];
            endpoint = "${serverIp}:${toString listenPort}";
            persistentKeepalive = 25;
          }
        ];
      };
    };
}
