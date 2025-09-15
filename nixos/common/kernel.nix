{ config, pkgs, ... }:

{
  # Kernel configuration for container support
  # boot.kernelModules = [ "overlay" ];
  
  # # Enable idmapped mounts support for rootless containers
  # boot.kernelParams = [
  #   "systemd.unified_cgroup_hierarchy=1"
  # ];

  # # Enable required kernel features for containers
  # boot.kernel.sysctl = {
  #   "kernel.unprivileged_userns_clone" = 1;
  #   "user.max_user_namespaces" = 28633;
  # };

  # Kernel patches to enable idmapped mounts support
  # boot.kernelPatches = [
  #   {
  #     name = "enable-idmapped-mounts";
  #     patch = null;
  #     extraConfig = ''
  #       USER_NS y
  #       OVERLAY_FS y
  #     '';
  #   }
  # ];

}
