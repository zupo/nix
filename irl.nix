# A Raspberry Pi Model 3 B hooked to Kkmoon 7 TFT portable monitor that will be used
# as a demo/play machine during Niteo IRL#6 in Marrakech.
#
# Usage:
# $ cd /etc/nixos && git clone https://github.com/zupo/nix.git
# $ mv /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
# $ ln -s /etc/nixos/nix/irl.nix /etc/nixos/configuration.nix
# $ mkdir /etc/nixos/secrets
# $ nano /etc/nixos/secrets/nevroni
# $ truncate -s -1 /etc/nixos/secrets/nevroni
# $ nixos-rebuild switch
#
# TODO:
# * boot to kiosk mode:
#    * https://gist.github.com/datakurre/cd29a985351e6b8c9bbc04532e5f9df0
#    * https://gist.github.com/domenkozar/03a1c3926c8172be0fcc6f567d3ab8ac?fbclid=IwAR3LZ4iIQeSXkw5QwmI_DRQt5SsFp7ApB7J-QoNxa2vNaYDsthOvx8gNJPw

{ config, pkgs, lib, ... }:
{

  imports = [
    ./minimal.nix
    ./features/common.nix
  ];


  boot.loader.raspberryPi.firmwareConfig = lib.mkForce ''
    gpu_mem=256

    # needed for the small portable HDMI display to work
    hdmi_safe=1
  '';

  # Add support for on-board wireless
  boot.kernelPackages = lib.mkForce pkgs.pkgs.linuxPackages_4_18;  # due to regression in 4.19
  hardware.enableRedistributableFirmware = true;
  networking.wireless.enable = true;
  networking.wireless.networks = {
    nevroni.psk = builtins.readFile /etc/nixos/secrets/nevroni;
    HUAWEI-B310-HAWDON.psk = builtins.readFile /etc/nixos/secrets/hawdon;
  };

}
