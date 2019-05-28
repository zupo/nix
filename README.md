# Getting started with NixOS on Raspberry Pi 3 Model B+

This is a step-by-step guide on diving into NixOS by installing and using it on a Raspberry Pi 3 Model B+.

The official documentation on running [NixOS on ARM](https://nixos.wiki/wiki/NixOS_on_ARM), and more specifically, [on a Raspberry Pi](https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi) is quite good. But it has to cover a lot of edge cases and old revisions, plus it assumes some prior experience with NixOS. I had none. I did however have the luxury of [@domenkozar](https://github.com/domenkozar) hand-holding me through instructions so that I could build my first NixOS install. But not everyone has the same privilege! And for those of you, this guide tries to provide enough hand-holding so that anyone with some *general* Linux experience is able to follow.

To make the guide even easier to follow, it is focused only on a single board: the Raspberry Pi 3 Model B+.

The end game is a robust and future-proof Media Center running on a Raspberry Pi 3.

## Assumptions

* The development machine that you will use to work through this guide, is a MacBook or a Linux machine you know well (and you can Google Linux alternatives for MacOS apps)
* The Raspberry Pi will use wired ethernet, and will get the IP via DHCP.
* The Raspberry Pi is connected to an HDMI display.
* You have a somewhat decent Internet connection.

## Minimal install

First, we'll do a minimal install of NixOS on your Raspberry Pi. Adding extra software on top of the minimal install is very easy and we'll do it later.

### Installing NixOs on the SD card

1. Go to https://hydra.nixos.org/search?query=sd_image and find the line that contains `nixos:release-18.09-aarch64`. 18.09 is the current stable version of NixOs.
2. Click on the `nixos.sd_image.aarch64-linux` part of the line to see the latest builds. Click on the most recent one that has passed successfully (green checkmark).
3. Click on the link in the `File   sd-image` line. Mine was `nixos-sd-image-18.09beta1819.76aafbf4bf4-aarch64-linux.img` and the URL was https://hydra.nixos.org/build/86448927/download/1/nixos-sd-image-18.09beta1819.76aafbf4bf4-aarch64-linux.img.
4. Use [Etcher](https://www.balena.io/etcher/) to flash the image onto your SD Card. Please use 8GB or bigger card.


### First boot

1. Put the NixOs SD card into the Pi's SD cart slot and turn it on. If all goes well, you should be dropped into a root shell.
2. I like to get SSH running ASAP, so that I can use my MacBook's keyboard and terminal emulator to copy over
commands. I'm a creature of comfort. You can skip this step if you want.

    ```bash
    [root@nixos:~]# passwd  # to set root password to be able to SSH into the Raspberry Pi
    [root@nixos:~]# systemctl start sshd  # start SSH service
    [root@nixos:~]# ifconfig  # to see which IP was assigned to the Raspberry Pi
    ```

3. Copy over the contents of [`minimal.nix`](https://github.com/zupo/nix/blob/master/minimal.nix) into `/etc/nixos/configuration.nix`.

    ```bash
    [root@nixos:~]# nano /etc/nixos/configuration.nix

    { config, pkgs, lib, ... }:
    {
      # NixOS wants to enable GRUB by default
      boot.loader.grub.enable = false;

      # if you have a Raspberry Pi 2 or 3, pick this:
      boot.kernelPackages = pkgs.linuxPackages_latest;

    ...
    ```

4. And we're ready to build our minimal configuration.

    ```bash
    [root@nixos:~]# nixos-rebuild switch
    building Nix...
    building the system configuration...
    these derivations will be built:

    ...
    ```

    The first build takes about 10 minutes, consequent ones are faster.

5. Reboot to see it if works.

### Cleanup

At this point, your Raspberry Pi should boot into the minimal NixOS configuration defined in [`minimal.nix`](https://github.com/zupo/nix/blob/master/minimal.nix). Let's do some cleanup before we continue.

```bash
[root@nixos:~]# nix-collect-garbage -d  # remove old pre-built configuration and all of its dependencies
[root@nixos:~]# nixos-rebuild switch  # remove old boot entries
[root@nixos:~]# reboot  # to be on the safe side
```


# Ready for features

And that's basically it! You have a minimal NixOS running on your Raspberry PI. Now browse `.nix` files in the [`features/` directory](https://github.com/zupo/nix/features), copy their configuration into your `/etc/nixos/configuration.nix` and re-run `nixos-rebuild switch`.

Let's try one for practice: the home theater software Kodi.

1. Add the following to `/etc/nixos/configuration.nix`:

    ```bash
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
    ```

2. Run `nixos-rebuild switch` and `reboot` when it's done.

## Where to go from here?

- I really liked the [one hour, hands-on tutorial](https://github.com/brainrape/nixos-tutorial) when starting out. I got the basic knowledge needed to follow the official NixOS documentation.

- Check out the fully-fledged [`tv.nix`](https://github.com/zupo/nix/tree/master/tv.nix) configuration I use on my Raspberry Pi. In there you have static IP configuration, automounting of NAS, importing from other `.nix` files and more.

- Keep the [cheatsheet](https://github.com/brainrape/nixos-tutorial/blob/master/cheatsheet.md) handy.


## Thanks

* [@domenkozar](https://github.com/domenkozar) for not shying away from my endless harassment on IM when I got stuck. Which was often. It truly is a testament to NixOS' design that Domen was able to debug and fix my problems from 2500 kilometers away. And that's only because all "system state" is in the `configuration.nix` file and not sprinkled among tens of opaque locations around the filesystem.
* The authors of [NixOS on ARM](https://nixos.wiki/wiki/NixOS_on_ARM) which is a treasure-trove of tips & tricks.
* Other folks on the #nixos-aarch64 IRC channel for support and insights.

## Tips & Tricks

* Configure static IP internet:
  
  ```bash
  $ ifconfig eth0 192.168.1.2 netmask 255.255.255.0 broadcast 192.168.1.255 up
  $ route add default gw 192.168.1.1
  ```



## TODO

* Pin the version of NixOS we are using, so we truly get a deterministic and future-proof build.
* Is this still true? How can I test it?
  ```
  * Note: The mainline kernel (tested with nixos kernel 4.18.7) does not include support for cpu frequency scaling on the Raspberry Pi. To get higher clock speed, set force_turbo=1 in /boot/config.txt

  ```
* Rename repo to `nixos` or sth.
