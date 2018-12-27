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

### Flashing the SD card

1. Download `sd-image-aarch64-linux.img` from https://www.cs.helsinki.fi/u/tmtynkky/nixos-arm/installer/.
2. Use [Etcher](https://www.balena.io/etcher/) to flash the image onto your SD Card. Please use 16GB or bigger, you'll make your life so much easier later on.

### Creating the swap partition

If you are just testing things out, you can skip this for now. But when you are ready to build a usable Media Center, you should do it. Raspberry Pi comes with only 1GB of RAM and running Kodi (and more) while building a new nixos generation will almost certainly mean you will run out of memory. Happened to me.

1. Download the official [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) image and use Etcher [Etcher](https://www.balena.io/etcher/) to flash it to a *different* SD card (4GB is enough).
2. Boot the Raspbian and insert your NixOS SD card into a card reader plugged in the Rasperry PI.
3. Run `parted` to create a swap partition:

    ```bash
    $ mount
    ...
    /dev/sdb2 on /media/pi/NIXOS_SD type ext4 (rw,nosuid,nodev,relatime,data=ordered,uhelper=udisks2)
    /dev/sdb1 on /media/pi/NIXOS_BOOT type vfat (rw,nosuid,nodev,relatime,uid=1000,gid=1000,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,showexec,utf8,flush,errors=remount-ro,uhelperudisks2)
    $ umount /dev/sdb1
    $ umount /dev/sdb2

    $ sudo parted
    (parted) print
    GNU Parted 3.2
    ...
    Disk /dev/sdb: 16.0GB
    Sector size (logica/physical): 512B/512B
    Partition table: msdos
    Disk Flags:

    Number   Start    End      Size     Type      File system   Flags
     1       8389kB   134MB    126MB    primary   fat16         boot
     2       134MB    2359MB   2225MB   primary   ext4

    (parted) mkpart
    Partition type? primary
    File system type? linux-swap
    Start? 14GB
    End? 100%

    (parted) print
    ...
    Number   Start    End      Size     Type      File system     Flags
     1       8389kB   134MB    126MB    primary   fat16           boot
     2       134MB    2359MB   2225MB   primary   ext4
     3       14.0GB   16.0GB   1981MB   primary   linux-swap(v1)  lba

    (parted) quit

### First boot

1. Put the NixOs SD card into the Pi's SD cart slot and turn it on. If all goes well, you should be dropped into a root shell.
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
    [root@nixos:~]# nix-channel --add https://nixos.org/channels/nixos-18.09 nixos

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

5. If you followed the advice and [prepared a swap partition in advance](https://github.com/zupo/nix#creating-the-swap-partition) you can now enable it.

    ```bash
    [root@nixos:~]# mkswap -L swap /dev/mmcblk0p3

    # append the following to your configuration.nix
    [root@nixos:~]# nano /etc/nixos/configuration.nix
    ...
        swapDevices = [ { label = "swap"; }];
    }

6. And we're ready to build our minimal configuration.

    ```bash
    [root@nixos:~]# nixos-rebuild switch
    building Nix...
    building the system configuration...
    these derivations will be built:

    ...
    ```

    Building will take some time and generate [lots of output](https://github.com/zupo/nix/blob/master/minimal.output). For me it took a little over an hour. Remember we told nix we want to use the latest stable release of NixOS, instead of the bleeding edge, so the entire distribution needs to be downloaded, built and configured.

7. Reboot.

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
* [@dezdeg](https://github.com/dezgeg) for providing pre-built images that boot on the Raspberry Pi. No chance I'd be able to do this myself.
* Other folks on the #nixos-aarch64 IRC channel for support and insights.

## TODO

* Update `configuration.nix` to use minimal.nix and features/.
* Pin the version of NixOS we are using, so we truly get a deterministic and future-proof build.
* Is this still true? How can I test it?
  ```
  * Note: The mainline kernel (tested with nixos kernel 4.18.7) does not include support for cpu frequency scaling on the Raspberry Pi. To get higher clock speed, set force_turbo=1 in /boot/config.txt

  ```
* Rename repo to `nixos` or sth.
