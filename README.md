```
          _       __              
   _    _(_)___  / /_  ____  _  __
  | |/|/ / / _ \/ __ \/ __ \| |/_/
  |__,__/_/_//_/_/_/_/\____/>  <  
                         /_/|_|  
```

# winbox

Run Windows in Docker on Linux. Simple CLI with interactive setup, GPU passthrough, and full VM management.

Powered by [dockur/windows](https://github.com/dockur/windows) and KVM.

## Features

- **Interactive Setup** - Guided wizard configures everything (RAM, CPU, disk, ports, language)
- **Intel iGPU Passthrough** - Hardware acceleration for video encoding and graphics
- **Shared Folders** - Easy file transfer between host and Windows
- **Post-Install Scripts** - Automate software installation with OEM scripts
- **Input Validation** - Catches configuration errors before they cause problems
- **Firewall Helper** - Copy-paste commands for UFW, firewalld, and iptables

## Requirements

- Linux (tested on Ubuntu 24.04)
- Docker with Compose v2
- KVM enabled (Intel VT-x or AMD-V in BIOS)
- User in `kvm` group: `sudo usermod -aG kvm $USER`

## Quick Start

```bash
# Download
curl -O https://raw.githubusercontent.com/abhishekbhardwaj/winbox/main/winbox
chmod +x winbox

# Install and configure Windows VM
./winbox install

# Start the VM
./winbox start
```

## Commands

| Command | Description |
|---------|-------------|
| `install` | Interactive setup wizard for new Windows VM |
| `start` | Start the Windows VM |
| `stop` | Stop the Windows VM gracefully |
| `restart` | Restart the Windows VM |
| `status` | Show VM status, resource usage, and connection info |
| `logs` | Show container logs |
| `config` | Display current docker-compose.yml |
| `edit` | Modify VM settings (RAM, CPU, ports) |
| `secure` | Manage web viewer security (password/disable) |
| `update` | Pull latest dockur/windows image |
| `self-update` | Update winbox script to the latest version |
| `firewall` | Show commands to open ports for LAN access |
| `remove-config` | Remove VM config (keeps data) |
| `nuke` | Remove everything including VM data (destructive!) |
| `version` | Show winbox version |

## Windows Versions

| Code | Version | Size |
|------|---------|------|
| `11` | Windows 11 Pro | 7.2 GB |
| `11l` | Windows 11 LTSC | 4.7 GB |
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | Windows 10 LTSC | 4.6 GB |
| `2022` | Windows Server 2022 | 6.0 GB |
| `2019` | Windows Server 2019 | 5.3 GB |

See all versions with `./winbox install`.

## Connecting to the VM

**During installation:** Open `http://<server-ip>:8006` in your browser to monitor progress.

**After installation:** Use RDP for the best experience:
- Windows: `mstsc` (built-in)
- Linux: Remmina, FreeRDP
- macOS: Microsoft Remote Desktop

Default credentials: `Docker` / `admin`

## Web Viewer Security

The web viewer (port 8006) provides browser-based access to your VM but is **open by default** with no authentication. This is fine for local development but risky on public networks.

**Options:**

| Method | Security | Use Case |
|--------|----------|----------|
| No protection | None | Local/private networks only |
| Password protection | HTTP Basic Auth | LAN access with trusted users |
| Disabled | Full | Production, use RDP only |

**Configure during setup:** The `install` wizard asks about web viewer security.

**Configure after setup:** Use `./winbox secure` to:
- Add or change password protection
- Remove password protection
- Disable/re-enable the web viewer entirely

**Recommendation:** For any internet-exposed VM, either disable the web viewer or use password protection. RDP with strong credentials is the most secure option.

## Configuration

All files are stored in `~/.winbox/`:
- `~/.winbox/docker-compose.yml` - VM configuration
- `~/.winbox/data/` - Virtual disk and storage
- `~/.winbox/shared/` - Shared folder (if enabled)
- `~/.winbox/oem/` - Post-install scripts (if enabled)

## Advanced: Discrete GPU Passthrough

For NVIDIA/AMD GPU passthrough, see the [dockur/windows GPU thread](https://github.com/dockur/windows/issues/22). This requires manual VFIO setup and is not handled by this script.

Example for AMD RX 570 ([source](https://github.com/dockur/windows/issues/22#issuecomment-3140386530)):

```yaml
environment:
  ARGUMENTS: >
    -device pcie-root-port,id=pcieport0,bus=pcie.0,chassis=1
    -device vfio-pci,host=01:00.0,bus=pcieport0,addr=00.0,multifunction=on
    -device vfio-pci,host=01:00.1,bus=pcieport0,addr=00.1
devices:
  - /dev/vfio/2
privileged: true
```

## License

MIT

## Development

### Releasing a new version

1. Bump the version:
   ```bash
   ./scripts/bump-version.sh patch  # 1.0.0 -> 1.0.1
   ./scripts/bump-version.sh minor  # 1.0.0 -> 1.1.0
   ./scripts/bump-version.sh major  # 1.0.0 -> 2.0.0
   ```

2. Commit and push:
   ```bash
   git add winbox
   git commit -m "Bump version to X.Y.Z"
   git push
   ```

3. GitHub Actions will automatically create a tagged release.

Users can then update with `./winbox self-update`.

## Credits

- [dockur/windows](https://github.com/dockur/windows) - The Docker image that makes this possible
