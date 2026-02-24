{
  config,
  pkgs,
  inputs,
  ...
}:
let
  firefox-addons = pkgs.nur.repos.rycee.firefox-addons;
  # Privacy Badger (EFF) - not in NUR generated set; addonId from manifest
  privacy-badger = firefox-addons.buildFirefoxXpiAddon {
    pname = "privacy-badger";
    version = "2025.12.9";
    addonId = "jid1-MnnxcxisBPnSXQ@jetpack";
    url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest-firefox.xpi";
    sha256 = "18ff75s641ymjmh9jfg4lyvahvzb1p89mypy5fcnqwpdvkfancpl";
    meta = with pkgs.lib; {
      homepage = "https://privacybadger.org/";
      description = "Privacy Badger automatically learns to block hidden trackers (EFF)";
      license = licenses.gpl3Only;
      platforms = platforms.all;
    };
  };
in
{
  programs.firefox = {
    enable = true;

    profiles.esc2 = {
      id = 0;
      name = "esc2";

      extensions.packages = with firefox-addons; [
        # uBlock Origin - uBlock0@raymondhill.net
        ublock-origin

        # Privacy Badger (EFF) - tracker blocking
        privacy-badger

        # Vimium - {d7742d87-e61d-4b78-b8a1-b469842139fa}
        vimium
      ];

      settings = {
        # General settings
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.newtab.url" = "about:blank";

        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.pbmode.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.donottrackheader.value" = 1;

        # Security settings
        "security.tls.insecure_fallback_hosts" = "";
        "security.tls.unrestricted_rc4_fallback" = false;

        # Performance settings
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = true;
        "browser.cache.offline.enable" = false;

        # UI settings
        "browser.uidensity" = 1; # Compact density
        "browser.tabs.tabmanager.enabled" = false;
        "browser.tabs.autoHide" = true;

        # Developer settings
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
      };

      # User preferences (user.js)
      userChrome = ''
        /* Hide tab bar when only one tab */
        #TabsToolbar {
          visibility: collapse !important;
        }

        /* Compact mode */
        :root {
          --tab-min-height: 32px !important;
        }
      '';

      # Search engines
      search = {
        default = "ddg";
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://nixos.wiki/index.php?search={searchTerms}";
              }
            ];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };
        };
      };
    };
  };
}
