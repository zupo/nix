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

  users.users.zupo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3mRrO/NGw6q9wysAFmtqw8jKy7U4R5o3Hb/CnbAKnuJAlAOJX4gXzkXEHJF++6sm4cEe8GPvdfWwgTM8ysV53qQCVlmCCbcYvel4WkpOAJqsWljuwCtoDpYRoGhM4EvPe4oFmZ7sHKKFqCA03eIohG32wXmHvc3BQCD6YbvT8r6gg39XDiM3cwxsro6y8qCeo4I+qnPtt3bksMU2QgzCj3G3tytW2ZhYmEQL9Cu8PGxXVNXvBtBwLJtUq6MV5aoF/DKImD7zc7sYA+kRH+NXtFtrD3IdW3/eTpOIZTN95cyx4sAkx4zF8Pxefww4YugH+cYo9ZFFlxidnHThQSJRZL0DwAdVK7rpNxW5538snAZclQx6F9PdmesJ60Kqn+h92OnoEFSjuY0Tct2qdXou10gJmspCu0VnFIntDOxIAGrvNFC3mHYLhhwf84YnoGOt0yaIF9K9ewevxcxjnKp9BXTEcMxvPCXieoIhF01hp9GssmcRNLqNyqNNgi1pgLDSkaFetq+liw15jsK6t4vYHfjMqg9ynZ9P/wrVl8hUZ0KK+DLyrUdAFO4oUxRwFyz1uv71RoYV7MDWi+XdxycR4cGdBwg//BV5+zPOIf+4gpVT6TQPi0svymYbBNLoQRbMEQHXiTmgPdQ09npIIQ9xyClP1KE1CpaFkCJ/lQWtmrQ==" ];
  };

}
