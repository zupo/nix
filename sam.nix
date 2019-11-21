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
#     $ mv configuration.nix configuration.nix.bak
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
  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = [ "/dev/sda" "/dev/sdb" ];
  };
  networking.hostName = "sam";
  # The mdadm RAID1s were created with 'mdadm --create ... --homehost=hetzner',
  # but the hostname for each machine may be different, and mdadm's HOMEHOST
  # setting defaults to '<system>' (using the system hostname).
  # This results mdadm considering such disks as "foreign" as opposed to
  # "local", and showing them as e.g. '/dev/md/hetzner:data0'
  # instead of '/dev/md/data0'.
  # This is mdadm's protection against accidentally putting a RAID disk
  # into the wrong machine and corrupting data by accidental sync, see
  # https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14 and onward.
  # We set the HOMEHOST manually go get the short '/dev/md' names,
  # and so that things look and are configured the same on all such
  # machines irrespective of host names.
  # We do not worry about plugging disks into the wrong machine because
  # we will never exchange disks between machines.
  environment.etc."mdadm.conf".text = ''
    HOMEHOST sam
  '';
  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.mdadmConf = config.environment.etc."mdadm.conf".text;
  # Network (Hetzner uses static IP assignments, and we don't use HDCP here)
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
  networking.nameservers = [ "8.8.8.8" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

  environment.systemPackages = with pkgs; [
    git
  ];
}
