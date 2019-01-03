# A Raspberry Pi hooked to Kkmoon 7 TFT portable monitor that will be used
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
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
     name = "broadcom-rpi3-extra";
     src = pkgs.fetchurl {
     url = 
"https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/54bab3d/brcm80211/brcm/brcmfmac43430-sdio.txt";
     sha256 = "19bmdd7w0xzybfassn7x4rb30l70vynnw3c80nlapna2k57xwbw7";
     };
     phases = [ "installPhase" ];
     installPhase = ''
     mkdir -p $out/lib/firmware/brcm
     cp $src $out/lib/firmware/brcm/brcmfmac43430-sdio.txt
     '';
     })
  ];
  networking.wireless.enable = true;
  networking.wireless.networks = {
    nevroni = {
      psk = builtins.readFile /etc/nixos/secrets/nevroni;
    };
  };

}
