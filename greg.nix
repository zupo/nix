# Greg, the GPU server
#
# Usage:
# - Create a new HostKey GPU server
# - Follow @infinisil install script
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
#     $ mv hardware-configuration.nix greg/hardware-configuration.nix
#     $ ln -s greg.nix configuration.nix
#     $ vim secrets/email && truncate -s -1 secrets/email && git update-index --assume-unchanged secrets/email
#     $ passwd  # set a new root password
#     $ nixos-rebuild switch
# $ ssh zupo@<IP>  # no password should be required, login with pubkey
#   $ su -
#   $ passwd kai
#   $ reboot

{ config, pkgs, lib, ... }:
{
  system.stateVersion = "19.03"; # No touchy!

  imports =
    [ # Include the results of the hardware scan.
      ./greg/hardware-configuration.nix
      ./features/common.nix
    ];

  # To allow selecting different generations in the console
  boot.loader.timeout = 60;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    # Potentially not all of these are strictly needed
    "virtio_net"
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_balloon"
    "virtio_console"
  ];

  networking = {
    hostName = "greg";
    useDHCP = false;
    defaultGateway = "5.39.219.1";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    usePredictableInterfaceNames = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "5.39.219.29";
      prefixLength = 20;
    }];
  };

  # I am not the only one working on this server
  users.users.nkk0 = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa 
AAAAB3NzaC1yc2EAAAADAQABAAABAQDnSx48d8cEphXNA9+waKfgasT4z/ppCJNHTwy5hmsFo6HFGY72UWxlknt23BPD0ZHZdIZwAFGhkMF+vI76EdHwGp6JjIicd7eUu4gvUIdCqoolNyTuhRCHo2gUokcbbwUtb484ZiITuPkn7ixOVLigX6uHD5t3fyHY6AixENbh/YX1PiIxPsyiJ5Rt9YKGnB5py2RfIxcyAeUyhFGW1anH3J/cq8hmgooiHqD875Uo/ejbJ4BvasIkGufn6nhG9tPPcWA0mTcYoiNFwfaqmyFNCLBRMHuGmwyiSKQb8AtVefFaRD2OQ9ut/aJYlty+ZkFjY3ObXH49ak0T/2qRipFx" 
];
  };

  # app user
  services.openssh.passwordAuthentication = lib.mkForce true;  # TODO: add support for pubkey auth from app
  users.users.kai = {
    isNormalUser = true;
  };

  # project dependencies
  nixpkgs.config.allowUnfree = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  environment.systemPackages = with pkgs; [
    (python37.withPackages(ps: with ps; [ (fire.overrideAttrs (old: { doInstallCheck = false; })) regex requests tqdm numpy tensorflowWithCuda ]))
  ];
}

