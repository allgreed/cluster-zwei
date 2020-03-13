{ config, pkgs, ... }:

{
  imports =
    [
      ./common.nix
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/580b58f9-9e0c-4a04-8712-07465d9d743c";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3d1e713a-2e72-448d-8337-81b5fa5b4506"; }
    ];

  deployment.targetHost = "cluster1.hs";
}
