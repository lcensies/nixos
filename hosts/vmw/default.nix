{ inputs, ... }:
{
	imports = [
		../../nixos/default-vm.nix
		inputs.disko.nixosModules.disko
		./hardware-configuration-vmware-vm.nix
	];
	
}
