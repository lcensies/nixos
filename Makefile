

vmware-vm:
	sudo nixos-rebuild switch --arg machineType '"vmware-vm"'

disko-vmware-vm:
	sudo nix --extra-experimental-features flakes --extra-experimental-features nix-command  run 'github:nix-community/disko/latest#disko-install' -- --flake '.#vmware-vm' --disk main /dev/sda

tb14:
	sudo nixos-rebuild switch --flake '.#thinkbook14'
	sudo nix-store --gc

tb14offline:
	sudo nixos-rebuild switch --flake '.#thinkbook14' --offline

disko-tb14:
	sudo nix --extra-experimental-features flakes --extra-experimental-features nix-command run 'github:nix-community/disko/latest#disko-install' -- --flake '.#thinkbook14' --disk main /dev/nvme0n1

rollback:
	sudo nixos-rebuild switch --flake '.#rollback'

configure:
	git submodule update --init --recursive
	[ -d ~/.dotfiles ] || ln -sv "$(shell pwd)/dotfiles" ${HOME}/.dotfiles
	rcup -v

home-manager:
	home-manager switch --flake '.#esc2'

home-manager-edit:
	home-manager edit --flake '.#esc2'

# Cleanup targets
clean:
	@echo "Cleaning Nix store garbage..."
	sudo nix-collect-garbage -d
	sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
	sudo nix-store --gc
	rm -r ~/.cache
	@echo "Garbage collection complete."


.PHONY: clean clean-boot clean-all

