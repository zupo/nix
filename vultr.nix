{ config, pkgs, ... }:

{
  imports =
    [
      ./vultr/hardware-configuration.nix
      ./features/common.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/vda";

  system.stateVersion = "18.09";
}
