{ config, pkgs, lib, ... }:
{
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # if you have a Raspberry Pi 2 or 3, pick this:
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough
  boot.kernelParams = ["cma=256M"];

  # File systems configuration for using the installer's partition layout
  fileSystems."/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  fileSystems."/mnt/nas" = {
      device = "//NAS/media";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
    };
  
  
  # Speed up builds
  nix.buildCores = 4;
  
  # TODO: kodi now uses openjdk so this might not be needed any more?
  nixpkgs.config = {
    allowUnfree = true;
  };

  networking = {
    hostName = "tv";
    interfaces.eth0.ipv4.addresses = [{
        address = "10.9.3.10";
        prefixLength = 24;
    }];
    defaultGateway = "10.9.3.1";
    nameservers = [ "10.9.3.1" ];
 };

  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };

  # Enable the X11 windowing system
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

  environment.systemPackages = with pkgs; [
    (import ./vim.nix)
    git
    wget
    curl
    pwgen
    links2
    ncdu
    iftop
    iotop
    rsync
    screen
    telnet
  ];

  programs.bash.enableCompletion = true;
  time.timeZone = "Europe/Ljubljana";

  users.users.zupo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3mRrO/NGw6q9wysAFmtqw8jKy7U4R5o3Hb/CnbAKnuJAlAOJX4gXzkXEHJF++6sm4cEe8GPvdfWwgTM8ysV53qQCVlmCCbcYvel4WkpOAJqsWljuwCtoDpYRoGhM4EvPe4oFmZ7sHKKFqCA03eIohG32wXmHvc3BQCD6YbvT8r6gg39XDiM3cwxsro6y8qCeo4I+qnPtt3bksMU2QgzCj3G3tytW2ZhYmEQL9Cu8PGxXVNXvBtBwLJtUq6MV5aoF/DKImD7zc7sYA+kRH+NXtFtrD3IdW3/eTpOIZTN95cyx4sAkx4zF8Pxefww4YugH+cYo9ZFFlxidnHThQSJRZL0DwAdVK7rpNxW5538snAZclQx6F9PdmesJ60Kqn+h92OnoEFSjuY0Tct2qdXou10gJmspCu0VnFIntDOxIAGrvNFC3mHYLhhwf84YnoGOt0yaIF9K9ewevxcxjnKp9BXTEcMxvPCXieoIhF01hp9GssmcRNLqNyqNNgi1pgLDSkaFetq+liw15jsK6t4vYHfjMqg9ynZ9P/wrVl8hUZ0KK+DLyrUdAFO4oUxRwFyz1uv71RoYV7MDWi+XdxycR4cGdBwg//BV5+zPOIf+4gpVT6TQPi0svymYbBNLoQRbMEQHXiTmgPdQ09npIIQ9xyClP1KE1CpaFkCJ/lQWtmrQ==" ];
  };

  environment.etc."gitconfig".text = ''
    [user]
      name = Nejc Zupan
      email = nejc.zupan@gmail.com

    [core]
      editor = vim
      excludesfile = /etc/gitignore

      # Highlight whitespace errors in git diff:
      whitespace = tabwidth=2,tab-in-indent,cr-at-eol,trailing-space

    [color]
      diff = auto
      status = auto
      branch = auto
      ui = auto

    [alias]
      ap = add -p
      cdiff = diff --cached
      sdiff = diff --staged
      st = status
      ci = commit
      cia = commit -v -a
      cp = cherry-pick
      br = branch
      co = checkout
      df = diff
      dfs = diff --staged
      l = log
      ll = log -p
      rehab = reset origin/master --hard
      pom = push origin master
      phm = push heroku master
      latest = for-each-ref --sort=-committerdate refs/heads/

    [push]
      default = simple

    [branch]
      autosetuprebase = always

    [help]
      autocorrect = 1

    [credential]
      helper = cache --timeout=3600
  '';

  environment.etc."gitignore".text = ''
    # Compiled source #
    ###################
    *.com
    *.class
    *.dll
    *.exe
    *.o
    *.so
    *.lo
    *.la
    *.rej
    *.pyc
    *.pyo

    # Packages #
    ############
    # it's better to unpack these files and commit the raw source
    # git has its own built in compression methods
    *.7z
    *.dmg
    *.gz
    *.iso
    *.jar
    *.rar
    *.tar
    #*.zip

    # Logs and databases #
    ######################
    *.log
    *.sql
    *.sqlite

    # OS generated files #
    ######################
    .DS_Store
    .DS_Store?
    ehthumbs.db
    Icon?
    Thumbs.db

    # Python projects related #
    ###########################
    *.egg-info
    .egg-info.installed.cfg
    *.pt.py
    *.cpt.py
    *.zpt.py
    *.html.py
    *.egg
    *.Python
  '';
}
