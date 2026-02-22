# Z-Wave USB Passthrough Issue

**Date:** 2026-02-02

## Summary

Z-Wave JS UI container was failing repeatedly with "Failed to open the serial port: No such device or address, cannot open /dev/zwave" errors. The Zooz 800 Z-Wave stick was not visible in the VM despite being physically connected.

## Root Cause

**Traefik OOM (Out of Memory) storm caused system instability that broke Proxmox USB passthrough.**

### Timeline (January 31, 2026)

| Time | Event |
|------|-------|
| 06:13:42 | Traefik OOM killed (~2GB RAM) |
| 06:16:11 | Traefik OOM killed again |
| 06:18:00 | Traefik OOM killed again |
| 06:21:34 | Traefik OOM killed again |
| 06:39:57 | Traefik OOM killed again |
| 06:48:38 | Z-Wave starts failing to open serial port |

The repeated OOM kills and memory pressure destabilized the system, causing Proxmox to drop the USB passthrough to the VM. The device remained connected to the Proxmox host but was no longer passed through to the VM.

## Symptoms

- `lsusb` in VM showed no Zooz device
- `/dev/serial/by-id/` directory did not exist in VM
- Container logs showed repeated "No such device or address" errors
- Container exited with code 128

## Resolution

1. Re-attached USB device via Proxmox Web UI:
   - VM → Hardware → Remove USB device
   - Add → USB Device → Select Zooz stick
2. Restarted container: `docker compose up -d zwave-js-ui`

## Traefik Memory Issue

Traefik was consuming ~2GB RAM and hitting its cgroup memory limit, triggering OOM kills.

**Previous state:** ~2GB usage, getting OOM killed
**Current state:** 34MB / 1GB limit (healthy)

The memory limit in `/home/docker/traefik/docker-compose.yaml` is now set to:
```yaml
mem_limit: 1g
mem_reservation: 256m
```

## Future Prevention Options

### Option 1: Monitor and Wait
Keep current USB device passthrough. The Traefik OOM issue appears resolved. Only change if problem recurs.

### Option 2: USB Controller Passthrough (More Resilient)
Pass through the entire USB controller via PCI passthrough instead of individual device. This survives USB device resets better.

Steps:
1. Identify USB controller: `lspci | grep -i usb`
2. Find which controller has the Zooz stick
3. Add as PCI device in Proxmox: VM → Hardware → Add → PCI Device
4. Remove old USB device passthrough
5. Reboot VM

**Note:** This dedicates the entire USB controller (all ports) to the VM.

## Key Commands

```bash
# Check if USB device is visible in VM
ls -la /dev/serial/by-id/

# Check for OOM events
journalctl --since "7 days ago" | grep -i "oom\|killed process"

# Check Traefik memory usage
docker stats traefik --no-stream

# Restart Z-Wave container
cd /home/docker/zwave-js-ui && docker compose up -d
```

## Related Services

- **Z-Wave JS UI:** `/home/docker/zwave-js-ui/docker-compose.yaml`
- **Traefik:** `/home/docker/traefik/docker-compose.yaml`
- **USB Device:** Zooz 800 Z-Wave Stick (usb-Zooz_800_Z-Wave_Stick_533D004242-if00)
