{ config, pkgs, lib, ... }:
{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # if you have a Raspberry Pi 2 or 3, pick this:
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  environment.systemPackages = with pkgs; [
    vimHugeX
    git
    wget
    curl
    pwgen
    links2
    ncdu
    iftop
    iotop
    rsync
    screen
    telnet
  ];

  programs.bash.enableCompletion = true;
  time.timeZone = "Europe/Ljubljana";
  networking.hostName = "tv";
}
