{ pkgs, ... }:

{
  networking.wg-quick.interfaces = let
    determineWhichKeys = a:
      if a == 1 then {
        priv = "/etc/vpn_key.key";
        pub = "y+psGTv+CANlwica4M3gVUQs7riXLTvFX3JWy14Tuks=";
      } else if a == 2 then {
        priv = "IVHJWvZM75yochmMV527KbCxrvyQsNSkWatxvhiE+jQ=";
        pub = "/etc/vpn_key2.key";
      } else
        throw "invalid number to choose public/private key pair";

    keys = determineWhichKeys 1;

    serverIp = "149.34.244.154";
    port = 51820;
    networkToBlock = "192.168.0.0/24";

    publicKey = keys.pub;
    privateKeyFile = keys.priv;
  in {
    wg0 = {
      address = [ "10.2.0.2/32" ];
      dns = [ "10.2.0.1" ];
      listenPort = port;

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

        # ${pkgs.iptables}/bin/iptables -t mangle \
        # -I OUTPUT 1\
        # -p tcp \
        # --dport 25565 \
        # -j ACCEPT

        # ${pkgs.iptables}/bin/iptables -t mangle \
        # -I OUTPUT 1\
        # -p tcp \
        # --sport 25565 \
        # -j ACCEPT

        # ${pkgs.iptables}/bin/iptables -t mangle \
        # -I OUTPUT 1\
        # -p udp \
        # --dport 25565 \
        # -j ACCEPT

        # ${pkgs.iptables}/bin/iptables -t mangle \
        # -I OUTPUT 1\
        # -p udp \
        # --dport 25565 \
        # -j ACCEPT

        # ${pkgs.iptables}/bin/iptables -A OUTPUT \
        # -m mark \
        # -- mark 10000 -j ACCEPT


      '';

      postDown = ''
        ${pkgs.iptables}/bin/iptables -D OUTPUT \
          ! -o wg0 \
          -m mark ! --mark $(wg show wg0 fwmark) \
          -m addrtype ! --dst-type LOCAL \
          -j REJECT
        ${pkgs.iptables}/bin/ip6tables -D OUTPUT \
          ! -o wg0 -m mark \
          ! --mark $(wg show wg0 fwmark) \
          -m addrtype ! --dst-type LOCAL \
          -j REJECT
      '';

      peers = [{
        inherit publicKey;
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "${serverIp}:${toString port}";
        persistentKeepalive = 25;
      }];
    };
  };
}
