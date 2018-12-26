{ config, pkgs, lib, ... }:
{
    # Enable X11 windowing system
    services.xserver.enable = true;
    services.xserver.videoDrivers = [ "modesetting" ];

    # Enable Kodi
    services.xserver.desktopManager.kodi.enable = true;

    # Enable slim autologin
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.displayManager.lightdm.autoLogin.enable = true;
    services.xserver.displayManager.lightdm.autoLogin.user = "kodi";

    # Define a user account
    users.extraUsers.kodi.isNormalUser = true;
}

