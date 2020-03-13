{ config, pkgs, ... }:

{
  imports =
    [
      ./common.nix
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/802f8282-427a-4db9-aa76-cf6119edb859";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9dffd288-47ce-4231-8075-bb09743c9f6f"; }
    ];

  deployment.targetHost = "cluster2.hs";
}
