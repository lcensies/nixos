


## TODO

- [ ] Home-manager with KDE config export
- [ ] Messenger
- [ ] VMs
- [ ] Copy notes
- [ ] Backups 

## KDE

- Export nix config

```
nix run github:nix-community/plasma-manager
```


## Optional

- [ ] Firefox extensions
- [ ] Chrome

## Home manager

```
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
nix-channel --update
```

- Config is at

 ~/.config/home-manager/home.nix

---

symlinkJoin - maybe will work for nekobox


```
[esc2@stable:/nix/store/jyj2n5dfd35ccz1y32nd7n7i0dq481c1-v2raya-2.2.5.1/bin]$ cat v2rayA 
#! /nix/store/1xhds5s320nfp2022yjah1h7dpv8qqns-bash-5.2p32/bin/bash -e
PATH=${PATH:+':'$PATH':'}
PATH=${PATH/':''/nix/store/7cbdf6ghrhksmb5n5i6mrbx0ghnnhzgk-v2ray-core-5.15.3/bin'':'/':'}
PATH='/nix/store/7cbdf6ghrhksmb5n5i6mrbx0ghnnhzgk-v2ray-core-5.15.3/bin'$PATH
PATH=${PATH#':'}
PATH=${PATH%':'}
export PATH
XDG_DATA_DIRS=${XDG_DATA_DIRS:+':'$XDG_DATA_DIRS':'}
XDG_DATA_DIRS=${XDG_DATA_DIRS/':''/nix/store/mmbnb8mk4sxxirsdl8pxzv0f6piaxzc2-assets/share'':'/':'}
XDG_DATA_DIRS='/nix/store/mmbnb8mk4sxxirsdl8pxzv0f6piaxzc2-assets/share'$XDG_DATA_DIRS
XDG_DATA_DIRS=${XDG_DATA_DIRS#':'}
XDG_DATA_DIRS=${XDG_DATA_DIRS%':'}
export XDG_DATA_DIRS
exec -a "$0" "/nix/store/jyj2n5dfd35ccz1y32nd7n7i0dq481c1-v2raya-2.2.5.1/bin/.v2rayA-wrapped"  "$@" 


```

## Garbage collector

```
 nix-env --delete-generations old
 nix-store --gc
```

or


```
sudo nix-collect-garbage -d

```

- delete everything older than one day
```
nix-env --delete-generations 1d
```

also clean boot

```
 nixos-rebuild boot 
```
