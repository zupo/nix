# A TV-mounted Raspberry Pi that acts as the Media Center and makes
# the TV "smart".

{ config, pkgs, lib, ... }:
{

  imports = [
    ./minimal.nix
    ./features/common.nix
    ./features/kodi.nix
  ];

}
