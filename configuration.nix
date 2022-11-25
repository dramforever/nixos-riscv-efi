{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ ./efi-image.nix ];

  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = true;
  };

  boot.kernelParams = [ "console=ttyS0" ];
  boot.initrd.kernelModules = [ "virtio-pci" "virtio-blk" "pci_host_generic" ];

  networking.hostName = "nixos-riscv-efi";

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXOS_EFI";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_ROOT";
    fsType = "ext4";
  };

  systemd.services."serial-getty@hvc0".enable = false;
  services.getty.autologinUser = "root";
}
