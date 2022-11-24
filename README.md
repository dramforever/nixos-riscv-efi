# NixOS EFI boot on RISC-V using systemd-boot

Just a demo for now. Very dirty code inside; you have been warned!

## Supported devices

[X] QEMU with U-Boot

Requires a properly configured, recent-ish U-Boot that provides a correct device tree, which is... hard to find on real hardware these days. I really hope one day vendors can do this right, but until then we might have to make do with hacky things like `/dtbs/${fdtfile}`.

## Usage

Prepare U-Boot and disk image:

```console
$ nix build -o uboot .#ubootQemuRiscv64Smode
$ nix build -o image .#nixos-image
$ cp image/efi-image.img .
$ chmod u+w efi-image.img
$ truncate -s4G efi-image.img  # Size to your liking
```

Boot the image:

```bash
qemu-system-riscv64 -M virt -m 2g -nographic -s \
  -kernel uboot/u-boot.bin \
  -drive id=image,file=efi-image.img,format=raw,if=virtio
```

## First boot

A temporary initial configuration (generated on the build system) is used for the first boot. It's easier to do this than to use `bootctl` on the 'wrong' architecture and on a disk that doesn't really exist.

Early on during the first boot:

- The root partition is expanded to fill the device
- The Nix database is initialized and the system profile is set to the booted closure
- The 'correct' bootloader configuration is installed with NixOS's systemd-boot configuration generator

From now on the system should behave as a regular NixOS EFI image.

## References

Largely based on the existing `sd-image.nix` code.
