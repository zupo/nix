# A TV-mounted Raspberry Pi that acts as the Media Center and makes
# the TV "smart".

# Usage:
# $ passwd zupo  # since SSH will be forbidden for root
# $ cd /etc/nixos && git clone https://github.com/zupo/nix.git
# $ mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
# $ ln -s /etc/nixos/nix/tv.nix /etc/nixos/configuration.nix
# $ mkdir /etc/nixos/secrets
# $ nano /etc/nixos/secrets/smb
# $ nano /etc/nixos/secrets/email
# $ nixos-rebuild switch

# Manual steps in Kodi (hopefully someday automated with nix):
# * `Remove this main menu item` for `Music videos`, `TV`, `Radio`             # I don't plan to use them
# * Add video source: /mnt/nas/Movies; This directory contains: Movies
# * Add video source: /mnt/nas/TV; This directory contains: TV shows
# * Settings -> System -> Audio -> Audio output device: vc4-hdmi, Analog       # So TV plays audio
# * Settings -> System -> Power saving -> Put display to sleep when idle: 10 min
# * Settings -> Interface -> Region default format: Central Europe
# * Settings -> Interface -> Timezone country: Slovenia

# TODO:
# * disable wifi and bt as I don't use them
# * install and configure Trakt
# * configure the OSMC Remote keymap
# * rpi-specific build of Kodi that supports GPU decoding of videos


{ config, pkgs, lib, ... }:
{

  imports = [
    ./rpi.nix
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
      device = "//nas/media";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/secrets/smb"];
    };


}
