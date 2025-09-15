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

  # Enable default libvirt network
  virtualisation.libvirtd.allowedBridges = [ "virbr0" ];

  # Start default libvirt network automatically
  systemd.services.libvirt-default-network = {
    description = "Start default libvirt network";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.libvirt}/bin/virsh net-start default";
      ExecStop = "${pkgs.libvirt}/bin/virsh net-destroy default";
    };
    wantedBy = [ "multi-user.target" ];
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
