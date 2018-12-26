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

### Preparing the SD card

1. Download `sd-image-aarch64-linux.img` from https://www.cs.helsinki.fi/u/tmtynkky/nixos-arm/installer/.
2. Insert the SD card into the MacBook.
3. Unmount (not eject) the SD card partition using the Disk Utility app.
4. Open up the Terminal app and run `diskutil list` and note down the device number of the SD card.
5. Run `sudo dd bs=1m if=sd-image-aarch64-linux.img of=/dev/rdiskN conv=sync`. Replace `N` with the SD card device number.
6. Monitor progress with `Ctrl+T`.

A better guide for the steps above is in the [official Raspberry Pi documentation](https://www.raspberrypi.org/documentation/installation/installing-images/).

### First boot

1. Put the SD card into the Pi and turn it on. If all goes well, you should be dropped into a root shell.
2. I like to get SSH running ASAP, so that I can use my MacBook's keyboard and terminal emulator to copy over
commands. I'm a creature of comfort:

    ```bash
    [root@nixos:~]# passwd  # to set root password to be able to SSH into the Raspberry Pi
    [root@nixos:~]# systemctl start sshd  # start SSH service
    [root@nixos:~]# ifconfig  # to see which IP was assigned to the Raspberry Pi
    ```

3. Now that we can SSH into the Pi, we can start with some RealWork™. Let's tell nix to use a stable release of NixOS.

    ```bash
    ~ $ ssh root@<Pi's IP>
    [root@nixos:~]# nix-channel --list 
    nixos https://nixos.org/channels/nixos-unstable

    # The pre-built ARM image that we downloaded and flashed onto the SD card
    # is configured to use the bleeding edge NixOS. We don't want that. We're
    # building a Media Center and we care about stability and future proofing.
    # Let's use the latest *stable* NixOS release.

    [root@nixos:~]# nix-channel --remove nixos
    [root@nixos:~]# nix-channel --add https://nixos.org/channels/nixos-18.09

    [root@nixos:~]# nix-channel --list
    nixos https://nixos.org/channels/nixos-18.09

    [root@nixos:~]# nix-channel --update
    # This will take some time, depending on your Internet connection.
    ```

4. Copy over the contents of [`minimal.nix`](https://github.com/zupo/nix/blob/master/minimal.nix) into `/etc/nixos/configuration.nix`.

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

5. And we're ready to build our minimal configuration.

    ```bash
    [root@nixos:~]# nixos-rebuild switch
    building Nix...
    building the system configuration...
    these derivations will be built:

    ...
    ```

    Building will take some time and generate [lots of output](https://github.com/zupo/nix/blob/master/minimal.output). For me it took a little over an hour. Remember we told nix we want to use the latest stable release of NixOS, instead of the bleeding edge, so the entire distribution needs to be downloaded, built and configured.

6. Reboot.

### Cleanup

At this point, your Raspberry Pi should boot into the minimal NixOS configuration defined in [`minimal.nix`](https://github.com/zupo/nix/blob/master/minimal.nix). Let's do some cleanup before we continue.

```bash
~ $ ssh root@<Pi's IP>
[root@nixos:~]# nix-collect-garbage -d  # remove old pre-built configuration and all of its dependencies
[root@nixos:~]# nixos-rebuild switch  # remove old boot entries
[root@nixos:~]# reboot
```


# Ready for features

And that's basically it! You have a minimal NixOS running on your Raspberry PI. Now browse `.nix` files in the [`features/` directory](https://github.com/zupo/nix/features), copy their configuration into your `/etc/nixos/configuration.nix` and re-run `nixos-rebuild switch`.

Let's try one for practice: the home theater software Kodi.

1. Add the following to `/etc/nixos/configuration.nix`:

    ```nix
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
    ```

2. Run `nixos-rebuild switch` and `reboot` when it's done.


## Thanks

* [@domenkozar](https://github.com/domenkozar) for not shying away from my endless harassment on IM when I got stuck. Which was often. It truly is a testament to NixOS' design that Domen was able to debug and fix my problems from 2500 kilometers away. And that's only because all "system state" is in the `configuration.nix` file and not sprinkled among tens of opaque locations around the filesystem.
* [@dezdeg](https://github.com/dezgeg) for providing pre-built images that boot on the Raspberry Pi. No chance I'd be able to do this myself.
* Other folks on the #nixos-aarch64 IRC channel for support and insights.

## TODO

* Update `configuration.nix` to use minimal.nix and features/.
* Figure out how to elegantly add a swap partition to the SD card
  ```
  # !!! Adding a swap file is optional, but strongly recommended!
  # swapDevices = [ { device = "/swapfile"; size = 1024; } ];
  ```
* Pin the version of NixOS we are using, so we truly get a deterministic and future-proof build.
* Is this still true? How can I test it?
  ```
  * Note: The mainline kernel (tested with nixos kernel 4.18.7) does not include support for cpu frequency scaling on the Raspberry Pi. To get higher clock speed, set force_turbo=1 in /boot/config.txt

  ```
