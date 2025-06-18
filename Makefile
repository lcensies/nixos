
configure:
	mkdir -p ~/.config/nix
	echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf

	nix-channel --add https://github.com/nix-community/plasma-manager/archive/trunk.tar.gz plasma-manager
	nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware
	nix-channel --update plasma-manager




.PHONY: update
home:
	home-manager switch --flake .#myprofile	--impure

.PHONY: dotfiles
dotfiles:
	git clone https://github.com/lcensies/dotfiles ~/.dotfiles
	rcup
