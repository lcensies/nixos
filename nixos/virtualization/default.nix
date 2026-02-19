{ config, pkgs, ... }:
{
  imports = [
    ./containers.nix
    ./openclaw.nix
  ];

  # Libvirt's default NAT network (`virbr0`) requires host IP forwarding.
  # Without this, guests can reach the gateway (192.168.122.1) but not the internet.
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    # Enable if you later add IPv6 on guests / routed networks.
    "net.ipv6.conf.all.forwarding" = 1;
  };
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    virtiofsd
    libguestfs
    libguestfs-with-appliance
    spice
    spice-gtk
    # qemu_kvm
    spice-protocol
    # win-virtio
    win-spice

    vagrant
    packer

    nemu
    #realvnc-vnc-viewer # Takes too long to build
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        # Now available by default
        #ovmf.enable = true;
        #ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    spiceUSBRedirection.enable = true;
  };

  # Enable default libvirt network
  virtualisation.libvirtd.allowedBridges = [ "virbr0" ];
  networking.firewall.trustedInterfaces = [ "virbr0"];

  # Start default libvirt network automatically
  systemd.services.libvirt-default-network = {
    description = "Start default libvirt network";
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Start the network
      ${pkgs.libvirt}/bin/virsh net-start default || true
      
      # Wait for virbr0 to be ready
      for i in {1..10}; do
        if ${pkgs.iproute2}/bin/ip link show virbr0 &>/dev/null; then
          break
        fi
        sleep 0.5
      done
      
      # Disable STP to prevent VPN from causing port state issues
      ${pkgs.iproute2}/bin/ip link set virbr0 type bridge stp_state 0
    '';
    preStop = ''
      ${pkgs.libvirt}/bin/virsh net-destroy default || true
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # Fix virbr0 bridge when VPN interferes (disables STP, reattaches vnet interfaces)
  systemd.services.fix-virbr0-after-vpn = {
    description = "Fix virbr0 bridge networking after VPN connection";
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
      # Only run if virbr0 exists
      if ${pkgs.iproute2}/bin/ip link show virbr0 &>/dev/null; then
        # Disable STP on virbr0 (prevents port from getting stuck in listening state)
        ${pkgs.iproute2}/bin/ip link set virbr0 type bridge stp_state 0 2>/dev/null || true
        
        # Attach any vnet interfaces that got detached
        for vnet in /sys/class/net/vnet*; do
          if [ -e "$vnet" ]; then
            vnet_name=$(basename "$vnet")
            # Check if it's not already attached to virbr0
            if ! ${pkgs.iproute2}/bin/ip link show "$vnet_name" | grep -q "master virbr0"; then
              ${pkgs.iproute2}/bin/ip link set "$vnet_name" master virbr0 2>/dev/null || true
            fi
          fi
        done
        
        # Ensure virbr0 is up
        ${pkgs.iproute2}/bin/ip link set virbr0 up 2>/dev/null || true
      fi
    '';
  };

  # Network monitor service that watches for route/link changes and triggers fix
  systemd.services.virbr0-network-monitor = {
    description = "Monitor network changes and fix virbr0";
    after = [ "network-online.target" "libvirt-default-network.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "5s";
    };
    script = ''
      # This service monitors network events and triggers virbr0 fixes
      ${pkgs.iproute2}/bin/ip monitor route link | while read -r line; do
        # Trigger fix service on any network change
        ${pkgs.systemd}/bin/systemctl start fix-virbr0-after-vpn.service --no-block || true
        
        # Debounce - wait a bit before processing next event
        sleep 2
      done
    '';
  };

  # Backup timer (runs less frequently as fallback)
  systemd.timers.fix-virbr0-periodic = {
    description = "Periodic backup check for virbr0 bridge";
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
      Unit = "fix-virbr0-after-vpn.service";
    };
    wantedBy = [ "timers.target" ];
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
