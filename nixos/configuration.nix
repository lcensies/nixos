{ config, lib, pkgs, ... }:

{ imports = [ 
      ./hardware-configuration.nix 
  ];


  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true; 
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  networking.hostName = "stable"; 
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; 

  time.timeZone = "Europe/Moscow";

  # Configure network proxy if necessary networking.proxy.default = "http://user:password@proxy:port/"; networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true; 
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us,ru";
  services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents. services.printing.enable = true;

  # Enable sound. hardware.pulseaudio.enable = true; OR
  services.pipewire = { enable = true; pulse.enable = true; };

  # Power management
  # powerManagement.enable = true;
  # KDE default
  # services.power-profiles-daemon.enable = false;
  # services.tlp.enable = true;

  # Enable touchpad support (enabled default in most desktopManager). services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.esc2 = { 
    isNormalUser = true; 
    home = "/home/esc2";
    createHome = true;
    extraGroups = [ "wheel" "qemu-libvirtd" "libvirtd" 
         "wheel" "video" "audio" "disk" "networkmanager"  ]; # Enable ‘sudo’ for the user. packages = with pkgs;
  };
 environment.etc."current-system-packages".text =
	let
	packages = builtins.map (p: "${p.name}") config.environment.systemPackages;

	sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);

	formatted = builtins.concatStringsSep "\n" sortedUnique;
	in
  formatted; 

  security.wrappers.nekoray_core = {
      capabilities = "cap_net_bind_service+ep cap_sys_admin+ep";
      owner = "root";
      group = "root";
      source = "${pkgs.nekoray.nekoray-core}/bin/nekoray_core";
  };


  security.sudo.extraRules = [
    { groups = [ "wheel" ]; commands = [ "/run/current-system/sw/bin/nekoray" ]; }
  ]; 
  
  #  nixpkgs.overlays = [(
  #    final: prev: {
  #      nekoray = prev.nekoray.overrideAttrs (oldAttrs: {
  #        postInstall = (oldAttrs.postInstall or "") + ''
  #          substituteInPlace $out/share/applications/nekoray.desktop \
  #            --replace "Exec=nekoray" "Exec=sudo nekoray"
  #        '';
  #      });
  #    }
  #  )];

  environment.systemPackages = with pkgs; [
    vim 
    neovim 
    git
    zip
    unzip
    wget

    nekoray
    #v2raya
    #xray    

    wl-clipboard-rs

    virt-manager
    virt-viewer
    spice 
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];

  programs.firefox.enable = true;



  # https://discourse.nixos.org/t/set-up-vagrant-with-libvirt-qemu-kvm-on-nixos/14653
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



  

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true; programs.gnupg.agent = { enable = true; 
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.spice-vdagentd.enable = true;
  # services.v2raya.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ ... ]; networking.firewall.allowedUDPPorts = [ ... ]; Or disable the firewall altogether. 
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system (/run/current-system/configuration.nix). This is useful in case you accidentally delete 
  # configuration.nix. system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine, and is used to maintain compatibility with application data (e.g. databases) 
  # created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason, even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from, so changing it will NOT upgrade your system - see 
  # https://nixos.org/manual/nixos/stable/#sec-upgrading for how to actually do that.
  #
# This value being lower than the current NixOS release does NOT mean your system is out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration, and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
 
  nix = {
    gc.automatic = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };



}

