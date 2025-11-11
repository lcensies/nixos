{ config, pkgs, ... }:

{
  # Private configuration
  # Add your personal packages, secrets, or configurations here
  
  environment.systemPackages = with pkgs; [
    # Example: Add private packages here
  ];
}
