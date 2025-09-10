# ThinkBook 14 Configuration

This directory contains the NixOS configuration for the ThinkBook 14 laptop.

## Files

- `default.nix` - Main configuration file that imports hardware config, disko, and enables passwordless sudo for wheel users
- `hardware-configuration-thinkbook14.nix` - Hardware-specific configuration (copied from `/etc/nixos/hardware-configuration.nix`)
- `disko.nix` - Disk partitioning configuration with LUKS encryption and LVM

## Usage

### Switch to ThinkBook 14 configuration:
```bash
make tb14
```

### Install with disko (for fresh installation):
```bash
make disko-tb14
```

### Rollback to original configuration:
```bash
make rollback
```

## Features

- LUKS encryption with LVM
- Passwordless sudo for wheel users
- Hardware-specific configuration for ThinkBook 14
- Disko-based disk partitioning for reproducible installations
