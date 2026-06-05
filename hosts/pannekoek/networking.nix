_: {
  networking = {
    interfaces.enp0s25 = {
      ipv4.addresses = [
        {
          address = "192.168.0.200";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = {
      address = "192.168.0.1";
      interface = "enp0s25";
    };
  };
}
