# VM Network + VPN Compatibility Fix

## Problem
When Amnezia VPN connects, VM connectivity breaks because:
- Spanning Tree Protocol (STP) on virbr0 bridge gets stuck in "listening" state
- VM virtual interfaces (vnet*) can't forward traffic
- virbr0 shows "NO-CARRIER" state even though vnet interfaces are attached

## Solution Implemented

### 1. Automatic STP Disable on Boot
The `libvirt-default-network` service now disables STP when starting the bridge.

### 2. Real-time Network Monitoring
A new `virbr0-network-monitor` service watches for network changes using `ip monitor`:
- Detects when VPN connects/disconnects
- Detects route changes
- Detects interface state changes
- Automatically triggers the fix service

### 3. Automatic Fix Service
The `fix-virbr0-after-vpn` service:
- Disables STP on virbr0
- Reattaches any detached vnet interfaces
- Ensures virbr0 stays in UP state

### 4. Backup Timer
A periodic timer runs every 10 minutes as a fallback.

## Files Modified
- `/home/esc2/repos/nixos/nixos/virtualization/default.nix` - NixOS configuration
- `/home/esc2/repos/nixos/fix-vm-network.sh` - Manual fix script

## How to Apply

```bash
sudo nixos-rebuild switch
```

After rebuild, verify services are running:
```bash
systemctl status virbr0-network-monitor.service
systemctl status libvirt-default-network.service
systemctl list-timers fix-virbr0-periodic
```

## Manual Fix (if needed)

If VM becomes unreachable after VPN connection:
```bash
~/repos/nixos/fix-vm-network.sh
```

## Testing

1. With VPN disconnected:
   ```bash
   ping 192.168.122.171
   ```

2. Connect Amnezia VPN

3. The network monitor should automatically fix virbr0 within seconds

4. Verify VM is still reachable:
   ```bash
   ping 192.168.122.171
   ```

## Monitoring

Check if the monitor is working:
```bash
# Watch for network events (Ctrl+C to stop)
journalctl -u virbr0-network-monitor.service -f

# Check fix service logs
journalctl -u fix-virbr0-after-vpn.service -n 50
```

## Troubleshooting

### VM still unreachable after VPN connects
```bash
# Check virbr0 status
ip link show virbr0

# Check if vnet is attached
ip link show master virbr0

# Check STP state
ip -d link show virbr0 | grep stp_state

# Manually run fix
~/repos/nixos/fix-vm-network.sh
```

### Network monitor not running
```bash
systemctl status virbr0-network-monitor.service
systemctl restart virbr0-network-monitor.service
```

## How It Works

1. **Boot**: libvirt starts default network, virbr0 created with STP disabled
2. **Network Monitor**: Continuously watches for any network changes
3. **VPN Connects**: Route changes detected by `ip monitor`
4. **Auto-Fix**: fix-virbr0-after-vpn service triggered immediately
5. **STP Disabled**: Traffic flows normally through virbr0
6. **VM Accessible**: Even with VPN active

## Root Cause Explained

Amnezia VPN was interfering with the bridge's Spanning Tree Protocol:
- STP is designed for loop prevention in complex bridge topologies
- When VPN connects, network topology changes trigger STP recalculation
- Bridge ports enter "listening" state (15-20 second delay before forwarding)
- VPN's rapid network changes prevent STP from reaching "forwarding" state
- Result: vnet0 stuck in "listening" state permanently

**Solution**: Disable STP entirely - not needed for simple VM bridge topology.
