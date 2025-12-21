{ config, pkgs, ... }:

{
  # Container tools packages
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    distrobox
    # K8s
    minikube
    kubectl
    kubernetes-helm
  ];

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;

  virtualisation = {
    docker = {
      enable = true;
      # Enable Docker daemon on boot
      enableOnBoot = true;
    };
  };

  # Add docker group to user
  users.users.esc2 = {
    extraGroups = [ "docker" ];
  };

}
