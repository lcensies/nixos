{ lib, pkgs, ...}:
{
	home = {
		packages = with pkgs; [
			hello
		];

		username = "esc2";
		homeDirectory = "/home/esc2";

		stateVersion = "24.05";

	};
}
