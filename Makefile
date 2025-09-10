

vmware-vm:
	sudo nixos-rebuild switch --arg machineType '"vmware-vm"'

disko-vmware-vm:
	sudo nix --extra-experimental-features flakes --extra-experimental-features nix-command  run 'github:nix-community/disko/latest#disko-install' -- --flake '.#vmware-vm' --disk main /dev/sda

