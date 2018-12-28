# A TV-mounted Raspberry Pi that acts as the Media Center and makes
# the TV "smart".

# Usage:
# $ cd /etc/nixos && git clone https://github.com/zupo/nix.git
# $ mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
# $ ln -s /etc/nixos/nix/tv.nix /etc/nixos/configuration.nix
# $ mkdir /etc/nixos/secrets
# $ nano /etc/nixos/secrets/smb
# $ nano /etc/nixos/secrets/email
# $ nixos-rebuild switch


{ config, pkgs, lib, ... }:
{

  imports = [
    ./minimal.nix
    ./features/common.nix
    ./features/kodi.nix
  ];

  boot.loader.raspberryPi.firmwareConfig = lib.mkForce ''
    gpu_mem=256
    decode_MPG2=${ builtins.readFile /etc/nixos/secrets/mpg2 }
  '';
 
  networking = {
    hostName = "tv";
    interfaces.eth0.ipv4.addresses = [{
        address = "10.9.3.10";
        prefixLength = 24;
    }];
    defaultGateway = "10.9.3.1";
    nameservers = [ "10.9.3.1" ];
 };

  fileSystems."/mnt/nas" = {
      device = "//NAS/media";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/secrets/smb"];
    };


}
