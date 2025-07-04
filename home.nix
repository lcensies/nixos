{ lib, pkgs, ...}:
{
	#imports = [
	#    <plasma-manager/modules>
	#];
	nixpkgs.config.allowUnfree = true;
	home = {
		packages = with pkgs; [
      neovim

			rcm
			telegram-desktop

			python3
			# vscodium

      # Only usable terminal
      kitty

			#Browser
			firefox
			chromium


			imv #image viewer

			#Color palette
			eyedropper


			#Video editor
			shotcut

			#Image editor
			pinta
			inkscape

			#Messaging app
			# signal-desktop
			#telegram-desktop

			#Office suite
			libreoffice

			#Font
			jetbrains-mono
			nerdfonts

			# Keepass
			keepassxc

			# Note taking
			obsidian
			drawio

			# Development
			vscode

		];



		username = "esc2";
		homeDirectory = "/home/esc2";

		stateVersion = "24.05";

	};


	#programs.plasma = {
	#    enable = true;
	#    shortcuts = {
	#      "ActivityManager"."switch-to-activity-fbbffe00-452d-4961-af86-d4f73cbc0221" = [ ];
	#      "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
	#      "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
	#      "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
	#      "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
	#      "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
	#      "kcm_touchpad"."Toggle Touchpad" = ["Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku,Touchpad Toggle" "Meta+Ctrl+Zenkaku Hankaku"];
	#      "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
	#      "kmix"."decrease_volume" = "Volume Down";
	#      "kmix"."decrease_volume_small" = "Shift+Volume Down";
	#      "kmix"."increase_microphone_volume" = "Microphone Volume Up";
	#      "kmix"."increase_volume" = "Volume Up";
	#      "kmix"."increase_volume_small" = "Shift+Volume Up";
	#      "kmix"."mic_mute" = ["Microphone Mute" "Meta+Volume Mute,Microphone Mute" "Meta+Volume Mute,Mute Microphone"];
	#      "kmix"."mute" = "Volume Mute";
	#      "ksmserver"."Halt Without Confirmation" = "none,,Shut Down Without Confirmation";
	#      "ksmserver"."Lock Session" = ["Meta+L" "Screensaver,Meta+L" "Screensaver,Lock Session"];
	#      "ksmserver"."Log Out" = "Ctrl+Alt+Del";
	#      "ksmserver"."Log Out Without Confirmation" = "none,,Log Out Without Confirmation";
	#      "ksmserver"."Reboot" = "none,,Reboot";
	#      "ksmserver"."Reboot Without Confirmation" = "none,,Reboot Without Confirmation";
	#      "ksmserver"."Shut Down" = "none,,Shut Down";
	#      "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
	#      "kwin"."Cycle Overview" = [ ];
	#      "kwin"."Cycle Overview Opposite" = [ ];
	#      "kwin"."Decrease Opacity" = "none,,Decrease Opacity of Active Window by 5%";
	#      "kwin"."Edit Tiles" = "Meta+T";
	#      "kwin"."Expose" = "Ctrl+F9";
	#      "kwin"."ExposeAll" = ["Ctrl+F10" "Launch (C),Ctrl+F10" "Launch (C),Toggle Present Windows (All desktops)"];
	#      "kwin"."ExposeClass" = "Ctrl+F7";
	#      "kwin"."ExposeClassCurrentDesktop" = [ ];
	#      "kwin"."Grid View" = "Meta+G";
	#      "kwin"."Increase Opacity" = "none,,Increase Opacity of Active Window by 5%";
	#      "kwin"."Kill Window" = "Meta+Ctrl+Esc";
	#      "kwin"."Move Tablet to Next Output" = [ ];
	#      "kwin"."MoveMouseToCenter" = "Meta+F6";
	#      "kwin"."MoveMouseToFocus" = "Meta+F5";
	#      "kwin"."MoveZoomDown" = [ ];
	#      "kwin"."MoveZoomLeft" = [ ];
	#      "kwin"."MoveZoomRight" = [ ];
	#      "kwin"."MoveZoomUp" = [ ];
	#      "kwin"."Overview" = "Meta+W";
	#      "kwin"."Setup Window Shortcut" = "none,,Setup Window Shortcut";
	#      "kwin"."Show Desktop" = "Meta+D";
	#      "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
	#      "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
	#      "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
	#      "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
	#      "kwin"."Switch Window Down" = "Meta+Alt+Down";
	#      "kwin"."Switch Window Left" = "Meta+Alt+Left";
	#      "kwin"."Switch Window Right" = "Meta+Alt+Right";
	#      "kwin"."Switch Window Up" = "Meta+Alt+Up";
	#      "kwin"."Switch to Desktop 1" = ["Meta+1" "Ctrl+F1,Ctrl+F1,Switch to Desktop 1"];
	#      "kwin"."Switch to Desktop 10" = "none,,Switch to Desktop 10";
	#      "kwin"."Switch to Desktop 11" = "none,,Switch to Desktop 11";
	#      "kwin"."Switch to Desktop 12" = "none,,Switch to Desktop 12";
	#      "kwin"."Switch to Desktop 13" = "none,,Switch to Desktop 13";
	#      "kwin"."Switch to Desktop 14" = "none,,Switch to Desktop 14";
	#      "kwin"."Switch to Desktop 15" = "none,,Switch to Desktop 15";
	#      "kwin"."Switch to Desktop 16" = "none,,Switch to Desktop 16";
	#      "kwin"."Switch to Desktop 17" = "none,,Switch to Desktop 17";
	#      "kwin"."Switch to Desktop 18" = "none,,Switch to Desktop 18";
	#      "kwin"."Switch to Desktop 19" = "none,,Switch to Desktop 19";
	#      "kwin"."Switch to Desktop 2" = ["Ctrl+F2" "Meta+2,Ctrl+F2,Switch to Desktop 2"];
	#      "kwin"."Switch to Desktop 20" = "none,,Switch to Desktop 20";
	#      "kwin"."Switch to Desktop 3" = ["Ctrl+F3" "Meta+3,Ctrl+F3,Switch to Desktop 3"];
	#      "kwin"."Switch to Desktop 4" = ["Ctrl+F4" "Meta+4,Ctrl+F4,Switch to Desktop 4"];
	#      "kwin"."Switch to Desktop 5" = "Meta+5,,Switch to Desktop 5";
	#      "kwin"."Switch to Desktop 6" = "none,,Switch to Desktop 6";
	#      "kwin"."Switch to Desktop 7" = "none,,Switch to Desktop 7";
	#      "kwin"."Switch to Desktop 8" = "none,,Switch to Desktop 8";
	#      "kwin"."Switch to Desktop 9" = "none,,Switch to Desktop 9";
	#      "kwin"."Switch to Next Desktop" = "none,,Switch to Next Desktop";
	#      "kwin"."Switch to Next Screen" = "none,,Switch to Next Screen";
	#      "kwin"."Switch to Previous Desktop" = "none,,Switch to Previous Desktop";
	#      "kwin"."Switch to Previous Screen" = "none,,Switch to Previous Screen";
	#      "kwin"."Switch to Screen 0" = "none,,Switch to Screen 0";
	#      "kwin"."Switch to Screen 1" = "none,,Switch to Screen 1";
	#      "kwin"."Switch to Screen 2" = "none,,Switch to Screen 2";
	#      "kwin"."Switch to Screen 3" = "none,,Switch to Screen 3";
	#      "kwin"."Switch to Screen 4" = "none,,Switch to Screen 4";
	#      "kwin"."Switch to Screen 5" = "none,,Switch to Screen 5";
	#      "kwin"."Switch to Screen 6" = "none,,Switch to Screen 6";
	#      "kwin"."Switch to Screen 7" = "none,,Switch to Screen 7";
	#      "kwin"."Switch to Screen Above" = "none,,Switch to Screen Above";
	#      "kwin"."Switch to Screen Below" = "none,,Switch to Screen Below";
	#      "kwin"."Switch to Screen to the Left" = "none,,Switch to Screen to the Left";
	#      "kwin"."Switch to Screen to the Right" = "none,,Switch to Screen to the Right";
	#      "kwin"."Toggle Night Color" = [ ];
	#      "kwin"."Toggle Window Raise/Lower" = "none,,Toggle Window Raise/Lower";
	#      "kwin"."Walk Through Windows" = "Alt+Tab";
	#      "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
	#      "kwin"."Walk Through Windows Alternative" = "none,,Walk Through Windows Alternative";
	#      "kwin"."Walk Through Windows Alternative (Reverse)" = "none,,Walk Through Windows Alternative (Reverse)";
	#      "kwin"."Walk Through Windows of Current Application" = "Alt+`";
	#      "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
	#      "kwin"."Walk Through Windows of Current Application Alternative" = "none,,Walk Through Windows of Current Application Alternative";
	#      "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" = "none,,Walk Through Windows of Current Application Alternative (Reverse)";
	#      "kwin"."Window Above Other Windows" = "none,,Keep Window Above Others";
	#      "kwin"."Window Below Other Windows" = "none,,Keep Window Below Others";
	#      "kwin"."Window Close" = ["Meta+Shift+Q" "Alt+F4,Alt+F4,Close Window"];
	#      "kwin"."Window Fullscreen" = "none,,Make Window Fullscreen";
	#      "kwin"."Window Grow Horizontal" = "none,,Expand Window Horizontally";
	#      "kwin"."Window Grow Vertical" = "none,,Expand Window Vertically";
	#      "kwin"."Window Lower" = "none,,Lower Window";
	#      "kwin"."Window Maximize" = "Meta+PgUp";
	#      "kwin"."Window Maximize Horizontal" = "none,,Maximize Window Horizontally";
	#      "kwin"."Window Maximize Vertical" = "none,,Maximize Window Vertically";
	#      "kwin"."Window Minimize" = "Meta+PgDown";
	#      "kwin"."Window Move" = "none,,Move Window";
	#      "kwin"."Window Move Center" = "none,,Move Window to the Center";
	#      "kwin"."Window No Border" = "none,,Toggle Window Titlebar and Frame";
	#      "kwin"."Window On All Desktops" = "none,,Keep Window on All Desktops";
	#      "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
	#      "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
	#      "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
	#      "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
	#      "kwin"."Window One Screen Down" = "none,,Move Window One Screen Down";
	#      "kwin"."Window One Screen Up" = "none,,Move Window One Screen Up";
	#      "kwin"."Window One Screen to the Left" = "none,,Move Window One Screen to the Left";
	#      "kwin"."Window One Screen to the Right" = "none,,Move Window One Screen to the Right";
	#      "kwin"."Window Operations Menu" = "Alt+F3";
	#      "kwin"."Window Pack Down" = "none,,Move Window Down";
	#      "kwin"."Window Pack Left" = "none,,Move Window Left";
	#      "kwin"."Window Pack Right" = "none,,Move Window Right";
	#      "kwin"."Window Pack Up" = "none,,Move Window Up";
	#      "kwin"."Window Quick Tile Bottom" = "Meta+Down";
	#      "kwin"."Window Quick Tile Bottom Left" = "none,,Quick Tile Window to the Bottom Left";
	#      "kwin"."Window Quick Tile Bottom Right" = "none,,Quick Tile Window to the Bottom Right";
	#      "kwin"."Window Quick Tile Left" = "Meta+Left";
	#      "kwin"."Window Quick Tile Right" = "Meta+Right";
	#      "kwin"."Window Quick Tile Top" = "Meta+Up";
	#      "kwin"."Window Quick Tile Top Left" = "none,,Quick Tile Window to the Top Left";
	#      "kwin"."Window Quick Tile Top Right" = "none,,Quick Tile Window to the Top Right";
	#      "kwin"."Window Raise" = "none,,Raise Window";
	#      "kwin"."Window Resize" = "none,,Resize Window";
	#      "kwin"."Window Shade" = "none,,Shade Window";
	#      "kwin"."Window Shrink Horizontal" = "none,,Shrink Window Horizontally";
	#      "kwin"."Window Shrink Vertical" = "none,,Shrink Window Vertically";
	#      "kwin"."Window to Desktop 1" = "Meta+!,,Window to Desktop 1";
	#      "kwin"."Window to Desktop 10" = "none,,Window to Desktop 10";
	#      "kwin"."Window to Desktop 11" = "none,,Window to Desktop 11";
	#      "kwin"."Window to Desktop 12" = "none,,Window to Desktop 12";
	#      "kwin"."Window to Desktop 13" = "none,,Window to Desktop 13";
	#      "kwin"."Window to Desktop 14" = "none,,Window to Desktop 14";
	#      "kwin"."Window to Desktop 15" = "none,,Window to Desktop 15";
	#      "kwin"."Window to Desktop 16" = "none,,Window to Desktop 16";
	#      "kwin"."Window to Desktop 17" = "none,,Window to Desktop 17";
	#      "kwin"."Window to Desktop 18" = "none,,Window to Desktop 18";
	#      "kwin"."Window to Desktop 19" = "none,,Window to Desktop 19";
	#      "kwin"."Window to Desktop 2" = "Meta+@,,Window to Desktop 2";
	#      "kwin"."Window to Desktop 20" = "none,,Window to Desktop 20";
	#      "kwin"."Window to Desktop 3" = "Meta+#,,Window to Desktop 3";
	#      "kwin"."Window to Desktop 4" = "Meta+$,,Window to Desktop 4";
	#      "kwin"."Window to Desktop 5" = "Meta+%,,Window to Desktop 5";
	#      "kwin"."Window to Desktop 6" = "none,,Window to Desktop 6";
	#      "kwin"."Window to Desktop 7" = "none,,Window to Desktop 7";
	#      "kwin"."Window to Desktop 8" = "none,,Window to Desktop 8";
	#      "kwin"."Window to Desktop 9" = "none,,Window to Desktop 9";
	#      "kwin"."Window to Next Desktop" = "none,,Window to Next Desktop";
	#      "kwin"."Window to Next Screen" = "Meta+Shift+Right";
	#      "kwin"."Window to Previous Desktop" = "none,,Window to Previous Desktop";
	#      "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
	#      "kwin"."Window to Screen 0" = "none,,Move Window to Screen 0";
	#      "kwin"."Window to Screen 1" = "none,,Move Window to Screen 1";
	#      "kwin"."Window to Screen 2" = "none,,Move Window to Screen 2";
	#      "kwin"."Window to Screen 3" = "none,,Move Window to Screen 3";
	#      "kwin"."Window to Screen 4" = "none,,Move Window to Screen 4";
	#      "kwin"."Window to Screen 5" = "none,,Move Window to Screen 5";
	#      "kwin"."Window to Screen 6" = "none,,Move Window to Screen 6";
	#      "kwin"."Window to Screen 7" = "none,,Move Window to Screen 7";
	#      "kwin"."view_actual_size" = "Meta+0";
	#      "kwin"."view_zoom_in" = ["Meta++" "Meta+=,Meta++" "Meta+=,Zoom In"];
	#      "kwin"."view_zoom_out" = "Meta+-";
	#      "mediacontrol"."mediavolumedown" = "none,,Media volume down";
	#      "mediacontrol"."mediavolumeup" = "none,,Media volume up";
	#      "mediacontrol"."nextmedia" = "Media Next";
	#      "mediacontrol"."pausemedia" = "Media Pause";
	#      "mediacontrol"."playmedia" = "none,,Play media playback";
	#      "mediacontrol"."playpausemedia" = "Media Play";
	#      "mediacontrol"."previousmedia" = "Media Previous";
	#      "mediacontrol"."stopmedia" = "Media Stop";
	#      "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
	#      "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
	#      "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
	#      "org_kde_powerdevil"."Hibernate" = "Hibernate";
	#      "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
	#      "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
	#      "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
	#      "org_kde_powerdevil"."PowerDown" = "Power Down";
	#      "org_kde_powerdevil"."PowerOff" = "Power Off";
	#      "org_kde_powerdevil"."Sleep" = "Sleep";
	#      "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
	#      "org_kde_powerdevil"."Turn Off Screen" = [ ];
	#      "org_kde_powerdevil"."powerProfile" = ["Battery" "Meta+B,Battery" "Meta+B,Switch Power Profile"];
	#      "plasmashell"."activate task manager entry 1" = "none,Meta+1,Activate Task Manager Entry 1";
	#      "plasmashell"."activate task manager entry 10" = "none,Meta+0,Activate Task Manager Entry 10";
	#      "plasmashell"."activate task manager entry 2" = "none,Meta+2,Activate Task Manager Entry 2";
	#      "plasmashell"."activate task manager entry 3" = "none,Meta+3,Activate Task Manager Entry 3";
	#      "plasmashell"."activate task manager entry 4" = "none,Meta+4,Activate Task Manager Entry 4";
	#      "plasmashell"."activate task manager entry 5" = "none,Meta+5,Activate Task Manager Entry 5";
	#      "plasmashell"."activate task manager entry 6" = "Meta+6";
	#      "plasmashell"."activate task manager entry 7" = "Meta+7";
	#      "plasmashell"."activate task manager entry 8" = "Meta+8";
	#      "plasmashell"."activate task manager entry 9" = "Meta+9";
	#      "plasmashell"."clear-history" = "none,,Clear Clipboard History";
	#      "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
	#      "plasmashell"."cycle-panels" = "Meta+Alt+P";
	#      "plasmashell"."cycleNextAction" = "none,,Next History Item";
	#      "plasmashell"."cyclePrevAction" = "none,,Previous History Item";
	#      "plasmashell"."manage activities" = "Meta+Q";
	#      "plasmashell"."next activity" = "Meta+A,none,Walk through activities";
	#      "plasmashell"."previous activity" = "Meta+Shift+A,none,Walk through activities (Reverse)";
	#      "plasmashell"."repeat_action" = "none,Meta+Ctrl+R,Manually Invoke Action on Current Clipboard";
	#      "plasmashell"."show dashboard" = "Ctrl+F12";
	#      "plasmashell"."show-barcode" = "none,,Show Barcode…";
	#      "plasmashell"."show-on-mouse-pos" = "Meta+V";
	#      "plasmashell"."stop current activity" = "Meta+S";
	#      "plasmashell"."switch to next activity" = "none,,Switch to Next Activity";
	#      "plasmashell"."switch to previous activity" = "none,,Switch to Previous Activity";
	#      "plasmashell"."toggle do not disturb" = "none,,Toggle do not disturb";
	#    };
	#    configFile = {
	#      "baloofilerc"."General"."dbVersion" = 2;
	#      "baloofilerc"."General"."exclude filters" = "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
	#      "baloofilerc"."General"."exclude filters version" = 9;
	#      "dolphinrc"."General"."ViewPropsTimestamp" = "2024,9,30,2,14,34.552";
	#      "dolphinrc"."KFileDialog Settings"."Places Icons Auto-resize" = false;
	#      "dolphinrc"."KFileDialog Settings"."Places Icons Static Size" = 22;
	#      "kactivitymanagerdrc"."activities"."fbbffe00-452d-4961-af86-d4f73cbc0221" = "Default";
	#      "kactivitymanagerdrc"."main"."currentActivity" = "fbbffe00-452d-4961-af86-d4f73cbc0221";
	#      "kded5rc"."Module-device_automounter"."autoload" = false;
	#      "kdeglobals"."General"."AccentColor" = "61,212,37";
	#      "kdeglobals"."General"."LastUsedCustomAccentColor" = "61,212,37";
	#      "kdeglobals"."WM"."activeBackground" = "49,54,59";
	#      "kdeglobals"."WM"."activeBlend" = "252,252,252";
	#      "kdeglobals"."WM"."activeForeground" = "252,252,252";
	#      "kdeglobals"."WM"."inactiveBackground" = "42,46,50";
	#      "kdeglobals"."WM"."inactiveBlend" = "161,169,177";
	#      "kdeglobals"."WM"."inactiveForeground" = "161,169,177";
	#      "krunnerrc"."General"."FreeFloating" = true;
	#      "krunnerrc"."Plugins"."baloosearchEnabled" = false;
	#      "krunnerrc"."Plugins"."browserhistoryEnabled" = false;
	#      "krunnerrc"."Plugins"."calculatorEnabled" = false;
	#      "krunnerrc"."Plugins"."helprunnerEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_appstreamEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_bookmarksrunnerEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_charrunnerEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_dictionaryEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_katesessionsEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_konsoleprofilesEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_kwinEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_placesrunnerEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_plasma-desktopEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_recentdocumentsEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_sessionsEnabled" = true;
	#      "krunnerrc"."Plugins"."krunner_spellcheckEnabled" = false;
	#      "krunnerrc"."Plugins"."krunner_webshortcutsEnabled" = false;
	#      "krunnerrc"."Plugins"."locationsEnabled" = false;
	#      "krunnerrc"."Plugins"."org.kde.activities2Enabled" = false;
	#      "krunnerrc"."Plugins"."unitconverterEnabled" = false;
	#      "krunnerrc"."Plugins/Favorites"."plugins" = "windows,krunner_services,krunner_sessions";
	#      "kwinrc"."Desktops"."Id_1" = "243da4e0-b9dd-4c3a-997a-dea48fe0975a";
	#      "kwinrc"."Desktops"."Id_2" = "4a0f5038-69c3-49cc-b075-1c690086acd0";
	#      "kwinrc"."Desktops"."Id_3" = "93d4d9bf-195e-4468-92f0-f78b70a2340e";
	#      "kwinrc"."Desktops"."Id_4" = "f4537246-8a68-4a42-aca9-3d9d36996807";
	#      "kwinrc"."Desktops"."Id_5" = "bff607b0-d7ad-4a3c-bfe1-9d45ab9a6dd9";
	#      "kwinrc"."Desktops"."Number" = 5;
	#      "kwinrc"."Desktops"."Rows" = 1;
	#      "kwinrc"."NightColor"."Active" = true;
	#      "kwinrc"."NightColor"."Mode" = "Constant";
	#      "kwinrc"."Tiling"."padding" = 4;
	#      "kwinrc"."Tiling/84311a97-b8ea-5fc5-9f11-fb0e89e25036"."tiles" = "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
	#      "kwinrc"."Xwayland"."Scale" = 2;
	#      "plasma-localerc"."Formats"."LANG" = "en_US.UTF-8";
	#    };
	#};
}
