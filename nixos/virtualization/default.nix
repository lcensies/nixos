{ config, pkgs, ... }:
{
  imports = [
    ./containers.nix
  ];
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    libguestfs
    spice
    spice-gtk
    # qemu_kvm
    spice-protocol
    win-virtio
    win-spice

    vagrant
    packer
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  users.users.esc2 = {
    extraGroups = [
      "qemu-libvirtd"
      "libvirtd"

      "video"
      "audio"
      "disk"
    ];
  };

  environment.sessionVariables = rec {
    VAGRANT_DEFAULT_PROVIDER = "libvirt";
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };


}
