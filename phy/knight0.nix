{ config, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6ba7bdfd-e06d-4b04-b568-471ffb024d5a";
      fsType = "ext4";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/7afa216c-54be-433e-885a-35c87acb7953"; }
    ];

  # -- HW CONFIGURATION END --

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  services.logind.lidSwitch = "ignore";
  services.openssh.enable = true;

  system.stateVersion = "19.03";

  deployment.targetHost = "cluster0.hs";
}
