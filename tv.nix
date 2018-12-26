# A TV-mounted Raspberry Pi that acts as the Media Center and makes
# the TV "smart".

{ config, pkgs, lib, ... }:
{

  imports = [
    ./minimal.nix
    ./features/kodi.nix
  ];

  fileSystems."/mnt/nas" = {
      device = "//NAS/media";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    };

}
