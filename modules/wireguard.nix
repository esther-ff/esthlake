{ pkgs, ... }:

{
  networking.wg-quick.interfaces = let
    # determineWhichKeys = a:
    #   if a == 1 then {
    #     priv = "/etc/vpn_key.key";
    #     pub = "y+psGTv+CANlwica4M3gVUQs7riXLTvFX3JWy14Tuks=";
    #   } else if a == 2 then {
    #     priv = "IVHJWvZM75yochmMV527KbCxrvyQsNSkWatxvhiE+jQ=";
    #     pub = "/etc/vpn_key2.key";
    #   } else
    #     throw "invalid number to choose public/private key pair";
    # keys = determineWhichKeys 1;

    keys = {
      priv = "/etc/mullvad-key";
      pub = "DVui+5aifNFRIVDjH3v2y+dQ+uwI+HFZOd21ajbEpBo=";
    };
    serverIp = "185.65.134.82";
    listenPort = 51820;
    networkToBlock = "192.168.0.0/24";

    publicKey = keys.pub;
    privateKeyFile = keys.priv;
  in {
    wg0 = {
      address = [ "10.65.225.175/32" "fc00:bbbb:bbbb:bb01::2:e1ae/128" ];

      dns = [ "100.64.0.17" ];
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
        endpoint = "${serverIp}:${toString listenPort}";
        persistentKeepalive = 25;
      }];
    };
  };
}
