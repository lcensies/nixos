{ inputs, ... }:
{
	imports = [
		../../backup-configuration.nix
	];
	
	# Allow wheel users to use sudo without password
	security.sudo.wheelNeedsPassword = false;
}
