
# ── Host auto-detection (DMI product_version) ──────────────────────────────
# Override with: make switch FLAKE_HOST=thinkbook14
_DMI_VER  := $(shell cat /sys/class/dmi/id/product_version 2>/dev/null)
_DMI_NAME := $(shell cat /sys/class/dmi/id/product_name    2>/dev/null)

ifeq ($(_DMI_VER),ThinkPad P16s Gen 4 AMD)
  FLAKE_HOST ?= p16s
  DISKO_DISK ?= /dev/nvme0n1
else ifeq ($(_DMI_VER),ThinkBook 14 G6+ IMH)
  FLAKE_HOST ?= thinkbook14
  DISKO_DISK ?= /dev/nvme0n1
else ifeq ($(_DMI_NAME),VMware Virtual Platform)
  FLAKE_HOST ?= vmware-vm
  DISKO_DISK ?= /dev/sda
else
  FLAKE_HOST ?= $(error Unknown machine (DMI product_version='$(_DMI_VER)'). Set FLAKE_HOST= manually.)
  DISKO_DISK ?= /dev/nvme0n1
endif

_DISKO_RUN = sudo nix --extra-experimental-features flakes \
               --extra-experimental-features nix-command \
               run 'github:nix-community/disko/latest#disko-install' -- \
               --flake '.#$(FLAKE_HOST)' --disk main $(DISKO_DISK)

# ── Main targets ────────────────────────────────────────────────────────────

switch:
	sudo nixos-rebuild switch --flake '.#$(FLAKE_HOST)'
	sudo nix-store --gc

offline:
	sudo nixos-rebuild --rollback switch --flake '.#$(FLAKE_HOST)' --offline

disko-install:
	$(_DISKO_RUN)

rollback:
	sudo nixos-rebuild switch --flake '.#rollback'

# ── Home Manager ────────────────────────────────────────────────────────────

home-manager:
	home-manager switch --flake '.#esc2' --impure

home-manager-edit:
	home-manager edit --flake '.#esc2'

# ── Setup ───────────────────────────────────────────────────────────────────

configure:
	git submodule update --init --recursive
	[ -d ~/.dotfiles ] || ln -sv "$(shell pwd)/dotfiles" ${HOME}/.dotfiles
	rcup -v

# ── Cleanup ─────────────────────────────────────────────────────────────────

clean:
	@echo "Cleaning Nix store garbage..."
	sudo nix-collect-garbage -d
	sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
	sudo nix-store --gc
	rm -r ~/.cache
	@echo "Garbage collection complete."

.PHONY: switch offline disko-install rollback \
        home-manager home-manager-edit configure clean
