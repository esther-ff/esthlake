{ pkgs, ... }:

{
  networking.wg-quick.interfaces =
  let 
      serverIp = "89.39.107.185";
      port = 51820;
      networkToBlock = "192.168.0.0/24";
  in {
    wg0 = {
      address = [ "10.2.0.2/32" ];
      dns = ["10.2.0.1"];
      listenPort = port;
      privateKeyFile = "/etc/vpn_key.key";

      postUp = ''
      # Mark packets on the wg0 interface
      wg set wg0 fwmark 51820

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
        publicKey = "IVHJWvZM75yochmMV527KbCxrvyQsNSkWatxvhiE+jQ=";
        allowedIPs = [ "0.0.0.0/0"];
        endpoint = "${serverIp}:${toString port}";
        persistentKeepalive = 25;
      }];
    };
  };
}
