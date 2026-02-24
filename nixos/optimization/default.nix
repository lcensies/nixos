{ ... }:
{
  # Adaptive readahead daemon — prefetches files based on usage patterns
  # https://github.com/miguel-b-p/preload-ng
  services.preload-ng.enable = true;
}
