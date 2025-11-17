{ config, pkgs, ... }:

let
  unstableTarball = fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
in

{
  imports = [
    ./kernel.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      #unstable = import unstableTarball {
      #  config = config.nixpkgs.config;
      #};
    };
  };

  # Overlay to fix fcitx5-with-addons: it has been moved from libsForQt5 to qt6Packages
  nixpkgs.overlays = [
    (final: prev: {
      libsForQt5 = prev.libsForQt5.overrideScope (final': prev': {
        fcitx5-with-addons = prev.qt6Packages.fcitx5-with-addons;
      });
      # Also provide it at the top level for backward compatibility
      fcitx5-with-addons = prev.qt6Packages.fcitx5-with-addons;
    })
  ];

  time.timeZone = "Europe/Moscow";

  # Enable internationalization support
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };

  environment.sessionVariables = rec {
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XCURSOR_SIZE = "64";
  };

  # FZF configuration
  environment.variables = {
    FZF_DEFAULT_OPTS = "--height 40% --reverse --border";
  };

  users.users.esc2 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "bluetooth"
      "audio"
      "networkmanager"
    ];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  environment.systemPackages = with pkgs; [
    bc
    vim
    neovim
    wget
    tmux
    freshfetch
    git
    git-lfs
    nodejs_24
    yazi
    rcm
    gnumake
    go
    ruby
    zsh
    starship
    kitty
    zoxide
    jq
    fzf
    ripgrep
    zsh-fzf-tab
    yq
    lazygit
    just
    tmuxinator
    zoxide
    atuin
    impala
    bluetuith
    nixfmt
    lsof
    libisoburn
    flatpak
    
    unzip
  
    # Additional development packages
    openssl
    # C/C++
    gcc
    clang
    llvmPackages_latest.llvm
    # Common debugger
    lldb
    # Python
    poetry
    uv
    # Rust
    cargo
    rustc

    devcontainer
    waypipe
    ffmpeg
    
    # LaTeX support
    texlive.combined.scheme-full

    awscli2

    # Linux kernel headers
    config.boot.kernelPackages.kernel.dev

    # rust-rover
#
    #wireshark

    qrencode # qr generator
  ];
  
  # MTP MOUNT
  services.gvfs.enable = true;

  # services.resolved.enable = true;
  # programs.nekoray.tunMode.enable = true;
  #programs.mtr.enable = true;
  #programs.gnupg.agent = {
  #  enable = true;
  #  enableSSHSupport = true;
  #};

  # Nix configuration with flakes support
  nix = {
    gc.automatic = true;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "esc2" ];
    };
  };

  services.openssh.enable = true;
  #services.printing.enable = true;

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Atuin zsh integration is handled manually in ~/.zshrc

  # Activation script to run input sources setup after rebuilds
  system.activationScripts.inputSourcesSetup = ''
    # Run input sources setup script if we're in a graphical session
    if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
      echo "Setting up input sources after rebuild..."
      /home/esc2/.scripts/setup-input-sources.sh || true
    fi
  '';

  # Doesn't work well with sway on current
  # hardware
  # services.logind.extraConfig = ''
  #   IdleAction=suspend
  # '';
  # IdleActionSec
  system.stateVersion = "22.11";

}
