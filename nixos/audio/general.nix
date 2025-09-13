{ config, pkgs, ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Override PulseAudio default.pa to comment out bluetooth modules
  # This helps with bluetooth connectivity issues as suggested by ArchWiki
  environment.etc."pulse/default.pa".text = ''
    #!/usr/bin/pulseaudio -nF
    #
    # PulseAudio configuration file for the system-wide daemon.
    # This file is part of PulseAudio.

    ### Automatically restore the volume of streams and devices
    load-module module-device-restore
    load-module module-stream-restore
    load-module module-card-restore

    ### Automatically augment property information from .desktop files
    ### stored in /usr/share/application
    load-module module-augment-properties

    ### Should be after module-*-restore modules
    ### Automatically restore the default sink/source when changed by the user
    ### during runtime
    ### NOTE: This should be as early as possible so that subsequent modules
    ### that look up the default sink/source get the right value
    load-module module-default-device-restore

    ### Automatically move streams to the default device if their sink/source
    ### becomes unavailable, similar to pipewire
    load-module module-rescue-streams

    ### Make sure we always have a sink around, even if it is a null sink.
    load-module module-always-sink

    ### Honour intended role device property
    load-module module-role-dbus

    ### Automatically suspend sinks/sources that become idle for too long
    load-module module-suspend-on-idle

    ### If autoexit on idle is enabled we want to make sure we only quit
    ### when no local session needs us anymore.
    .ifexists module-console-kit.so
    load-module module-console-kit
    .endif
    .ifexists module-systemd-login.so
    load-module module-systemd-login
    .endif

    ### Enable positioned event sounds
    load-module module-position-event-sounds

    ### Cork music/video streams when a phone stream is active
    load-module module-role-cork

    ### Block audio recording for snap confined applications
    .ifexists module-snap-policy.so
    load-module module-snap-policy
    .endif

    ### Modules to allow autoloading of filters on demand.
    ### Should be loaded after module-role-cork so that it can detect
    ### the "filter" role.
    .ifexists module-filter-apply.so
    load-module module-filter-apply
    .endif

    ### Use the static hw:0,0 device by default
    set-default-sink output
    set-default-source input

    ### Automatically load driver modules for hardware (audio cards and so on)
    .ifexists module-udev-detect.so
    load-module module-udev-detect
    .else
    ### Use the static hw:0,0 device by default
    ### Automatically determine the best available audio device and
    ### set it as the default device. This is a fallback for when
    ### module-udev-detect is not available.
    .ifexists module-detect.so
    load-module module-detect
    .endif
    .endif

    ### Automatically load driver modules for Bluetooth hardware
    #.ifexists module-bluetooth-policy.so
    #load-module module-bluetooth-policy
    #.endif

    .ifexists module-bluetooth-discover.so
    #load-module module-bluetooth-discover
    .endif

    ### Load several protocols
    .ifexists module-esound-protocol-unix.so
    load-module module-esound-protocol-unix
    .endif
    load-module module-native-protocol-unix

    ### Network access (may be configured with paprefs, so leave this commented
    ### here, if enabled elsewhere)
    #load-module module-esound-protocol-tcp
    #load-module module-native-protocol-tcp
    #load-module module-zeroconf-publish

    ### Load the RTP receiver module (also configured via paprefs, see above)
    #load-module module-rtp-recv

    ### Load the RTP sender module (also configured via paprefs, see above)
    #load-module module-rtp-send

    ### Load additional modules from GSettings. This can be configured with the
    ### paprefs tool. Please keep in mind that the modules configured by paprefs
    ### will be loaded after the modules configured by /etc/pulse/default.pa.
    .ifexists module-gsettings.so
    load-module module-gsettings
    .endif
  '';

  environment.systemPackages = with pkgs; [
    pulseaudio
    pulsemixer
  ];
}
