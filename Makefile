
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

# ── Remote xeon-ws (build on this machine, activate over SSH) ────────────────
# Override: make deploy-xeon-ws REMOTE_XEON=esc2@192.168.31.39
REMOTE_XEON ?= esc2@192.168.31.39
# Destination on the remote for rsync (used by on-host: cd ~/nixos-deploy && nixos-rebuild …).
XEON_REMOTE_DIR ?= ~/nixos-deploy
NIX ?= nix --extra-experimental-features 'nix-command flakes'
XEON_MAX_JOBS ?= 1
XEON_CORES ?= 2
XEON_NIX_FLAGS = --max-jobs $(XEON_MAX_JOBS) --cores $(XEON_CORES) --option builders-use-substitutes true

# Parsed from REMOTE_XEON for podman deploy (override DEPLOY_SSH_* only if needed).
DEPLOY_SSH_USER ?= $(firstword $(subst @, ,$(REMOTE_XEON)))
DEPLOY_SSH_HOST ?= $(lastword $(subst @, ,$(REMOTE_XEON)))

# deploy-rs (flake `deploy.nodes.xeon-ws`, remoteBuild = false → build locally).
# --skip-checks avoids `nix flake check` (would evaluate every flake output, e.g. broken vmw + heavy checks).
# For cgroup limits on builders, use deploy-xeon-ws-podman (host nix-daemon ignores client cgroups).
deploy-xeon-ws:
	cd "$(CURDIR)" && $(NIX) run ".#deploy-rs" -- ".#xeon-ws" --skip-checks -- \
	  --extra-experimental-features "nix-command flakes" $(XEON_NIX_FLAGS)

# Podman: caps RAM/CPU for the whole build+deploy (see scripts/deploy-xeon-ws-podman.sh).
# Override: make deploy-xeon-ws-podman REMOTE_XEON=esc2@HOST MEMORY=12g CPUS=3 XEON_MAX_JOBS=1 XEON_CORES=2
MEMORY ?= 16g
CPUS ?= 4

deploy-xeon-ws-podman:
	MEMORY="$(MEMORY)" CPUS="$(CPUS)" MAX_JOBS="$(XEON_MAX_JOBS)" BUILD_CORES="$(XEON_CORES)" DEPLOY_SSH_USER="$(DEPLOY_SSH_USER)" DEPLOY_SSH_HOST="$(DEPLOY_SSH_HOST)" \
	  "$(CURDIR)/scripts/deploy-xeon-ws-podman.sh"

# Same idea with nixos-rebuild: local build when --target-host is set and --build-host omitted
nixos-remote-switch-xeon-ws:
	cd "$(CURDIR)" && $(NIX) run nixpkgs#nixos-rebuild -- switch \
	  --flake ".#xeon-ws" \
	  --target-host "$(REMOTE_XEON)" \
	  --use-remote-sudo \
	  --option builders-use-substitutes true \
	  --max-jobs $(XEON_MAX_JOBS) \
	  --cores $(XEON_CORES)

# Mirror this repo to the remote (then SSH and run nixos-rebuild there).
# Excludes Nix result symlinks and direnv; --delete drops paths removed locally.
# Untracked files (e.g. gitignored `.env`) are copied if present.
# Override: make rsync-xeon-ws REMOTE_XEON=esc2@host XEON_REMOTE_DIR='~/nixos-deploy'
rsync-xeon-ws:
	rsync -avz --delete \
	  --exclude 'result' --exclude 'result-*' \
	  --exclude '.direnv' \
	  "$(CURDIR)/" "$(REMOTE_XEON):$(XEON_REMOTE_DIR)/"

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
        deploy-xeon-ws deploy-xeon-ws-podman \
        nixos-remote-switch-xeon-ws rsync-xeon-ws \
        home-manager home-manager-edit configure clean
