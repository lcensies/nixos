{ lib, ... }:

{
  services.flatpak.enable = true;
  

  # Configure flatpak remotes - include default flathub and add flathub-beta
  # services.flatpak.remotes = [
  #   {
  #     name = "flathub";
  #     location = "https://flathub.org/repo/flathub.flatpakrepo";
  #   }
  #   {
  #     name = "flathub-beta";
  #     location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
  #   }
  # ];

  # services.flatpak.update.auto.enable = false;
  # services.flatpak.uninstallUnmanaged = false;

  # # Add here the flatpaks you want to install
  # # Format: { appId = "app.id"; origin = "remote-name"; }
  services.flatpak.packages = [
    #{ appId = "com.brave.Browser"; origin = "flathub"; }
    { appId = "com.obsproject.Studio"; origin = "flathub"; }
    { appId = "us.zoom.Zoom";  origin = "flathub"; }
    # Lutris is used instead
    # { appId = "com.valvesoftware.Steam"; origin = "flathub"; }
    # { appId = "com.valvesoftware.Steam.CompatibilityTool.Proton"; origin = "flathub"; }
    # Commented out due to geo-blocking (HTTP 451) from JetBrains servers
    # { appId = "com.jetbrains.RustRover"; origin = "flathub"; }
    { appId = "net.lutris.Lutris"; origin = "flathub"; }
    #"im.riot.Riot"
  ];
}
