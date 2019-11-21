# Sam, the GPU server
#
# Usage:
# - Create new Hetzner GPU server
# - Boot the server into Rescue mode
# - Follow https://gist.github.com/nh2/ebc27311731f53ee623ae781ca25103f
#   - Change IP to main IP
#   - Change ssh-rsa pubkey to your key
#   - Change hostname from `hetzner` to `sam`
# $ ssh root@<IP>
#   $ nix-channel --add https://nixos.org/channels/nixos-19.03 nixpkgs
#   $ nix-channel --update
#   $ vim /etc/nixos/configuration.nix  # add git to environment.systemPackages
#   $ nixos-rebuild switch
#   $ cd /etc/nixos
#     $ git init
#     $ git remote add origin https://github.com/zupo/nix.git
#     $ git pull
#     $ git checkout master
#     $ mv configuration.nix configuration.nix.orig
#     $ mv hardware-configuration.nix sam/hardware-configuration.nix
#     $ ln -s sam.nix configuration.nix
#     $ vim secrets/email && truncate -s -1 secrets/email && git update-index --assume-unchanged secrets/email
#     $ passwd  # set a new root password
#     $ nixos-rebuild switch
# $ ssh zupo@<IP>  # no password should be required, login with pubkey
#   $ su -
#   $ reboot

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./sam/hardware-configuration.nix
      ./features/common.nix
    ];
  
  # Use GRUB2 as the boot loader because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };

  # Set hostname for networrking and RAID1
  networking.hostName = "sam";
  environment.etc."mdadm.conf".text = ''
    HOMEHOST sam
  '';
  boot.initrd.mdadmConf = config.environment.etc."mdadm.conf".text;

  # Network
  networking.useDHCP = false;
  networking.interfaces."enp0s31f6".ipv4.addresses = [
    {
      address = "95.216.240.244";
      prefixLength = 24;
    }
  ];
  networking.interfaces."enp0s31f6".ipv6.addresses = [
    {
      address = "2a01:4f9:2b:230b::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "95.216.240.193";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp0s31f6"; };
  networking.nameservers = [ "213.133.98.98" "213.133.99.99" "213.133.100.100" ];  # https://wiki.hetzner.de/index.php/Hetzner_Standard_Name_Server/en

  system.stateVersion = "19.03"; # No touchy!
}
