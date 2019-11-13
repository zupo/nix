# A bunch of things I expect to have on every machine I work with.

{ config, pkgs, lib, ... }:
{

  # Niceties
  programs.bash.enableCompletion = true;
  environment.variables.EDITOR = "vim";
  time.timeZone = "UTC";

  # My usual account
  users.users.zupo = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3mRrO/NGw6q9wysAFmtqw8jKy7U4R5o3Hb/CnbAKnuJAlAOJX4gXzkXEHJF++6sm4cEe8GPvdfWwgTM8ysV53qQCVlmCCbcYvel4WkpOAJqsWljuwCtoDpYRoGhM4EvPe4oFmZ7sHKKFqCA03eIohG32wXmHvc3BQCD6YbvT8r6gg39XDiM3cwxsro6y8qCeo4I+qnPtt3bksMU2QgzCj3G3tytW2ZhYmEQL9Cu8PGxXVNXvBtBwLJtUq6MV5aoF/DKImD7zc7sYA+kRH+NXtFtrD3IdW3/eTpOIZTN95cyx4sAkx4zF8Pxefww4YugH+cYo9ZFFlxidnHThQSJRZL0DwAdVK7rpNxW5538snAZclQx6F9PdmesJ60Kqn+h92OnoEFSjuY0Tct2qdXou10gJmspCu0VnFIntDOxIAGrvNFC3mHYLhhwf84YnoGOt0yaIF9K9ewevxcxjnKp9BXTEcMxvPCXieoIhF01hp9GssmcRNLqNyqNNgi1pgLDSkaFetq+liw15jsK6t4vYHfjMqg9ynZ9P/wrVl8hUZ0KK+DLyrUdAFO4oUxRwFyz1uv71RoYV7MDWi+XdxycR4cGdBwg//BV5+zPOIf+4gpVT6TQPi0svymYbBNLoQRbMEQHXiTmgPdQ09npIIQ9xyClP1KE1CpaFkCJ/lQWtmrQ==" ];
  };

  # NTP clock synchronization
  services.timesyncd.enable = true;

  # Harden SSH
  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    permitRootLogin = lib.mkForce "no";
    passwordAuthentication = false;
  };

  # Filter incoming traffic
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  # Install things I'm used to having around
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

  environment.etc."gitconfig".text = ''
    [user]
      name = Nejc Zupan
      email = ${ builtins.readFile /etc/nixos/secrets/email }

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
      helper = cache --timeout=86400
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
