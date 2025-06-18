{config, pkgs, ...}:
{

	#environment.systemPackages = [ pkgs.nekoray ];

  programs.nekoray = {
    enable = true;
    tunMode = {
      enable = true;
    };
  };
}

