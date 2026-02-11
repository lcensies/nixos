{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # jetbrains.rust-rover  # Installed via flatpak instead
    goose-cli
    awscli2
    # config.boot.kernelPackages.kernel.dev
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

    opencode
  ];
}
