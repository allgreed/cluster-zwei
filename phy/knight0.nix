{ config, pkgs, ... }:

{
  imports =
    [
      ./common.nix
    ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6ba7bdfd-e06d-4b04-b568-471ffb024d5a";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7afa216c-54be-433e-885a-35c87acb7953"; }
    ];

  deployment.targetHost = "cluster0.hs";
}
