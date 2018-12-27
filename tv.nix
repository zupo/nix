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

  swapDevices = [ { label = "swap"; }];

}
