# DNS-over-HTTPS Debian Package

Complete Debian package for DNS-over-HTTPS with systemd integration, intelligent upgrade handling, and port 53 conflict management.

## Quick Start

### Installation
```bash
sudo apt install ./dns-over-https-1.0.0-amd64.deb
```

### Basic Setup
```bash
# 1. Resolve port 53 conflict with systemd-resolved
sudo doh-resolve disable

# 2. Configure DNS-over-HTTPS
sudo nano /etc/dns-over-https/doh-client.conf

# 3. Start service
sudo systemctl start doh-client
sudo systemctl enable doh-client

# 4. Test DNS
dig @127.0.0.1
```

## Key Features

- ✅ **Intelligent Upgrades**: Only restarts if service was running before upgrade
- ✅ **systemd-resolved Integration**: One-command to resolve port 53 conflicts
- ✅ **CLI Tools**: `doh-ctl`, `doh-resolve`
- ✅ **Security**: Unprivileged user execution
- ✅ **Documentation**: Man pages, examples, comprehensive guides

## Managing systemd-resolved Conflicts

### Problem
Both DNS-over-HTTPS client and systemd-resolved try to use port 53.

### Solution
Use `doh-resolve`:

```bash
# Check current status
doh-resolve status

# Use DNS-over-HTTPS (disable systemd-resolved stub listener)
sudo doh-resolve disable

# Revert to systemd-resolved
sudo doh-resolve enable

# Interactive configuration
sudo doh-resolve configure

# Check what's on port 53
doh-resolve check
```

Via `doh-ctl`:
```bash
sudo doh-ctl resolve status
sudo doh-ctl resolve disable
```

## CLI Tools

### doh-ctl - Service Control
```bash
doh-ctl client start           # Start client service
doh-ctl client stop            # Stop client service
doh-ctl client restart         # Restart client service
doh-ctl client status          # Client status
doh-ctl client logs            # Show client logs (last 50 lines)
doh-ctl client follow          # Follow client logs in real-time
doh-ctl server start           # Start server service
doh-ctl server stop            # Stop server service
doh-ctl server restart         # Restart server service
doh-ctl server status          # Server status
doh-ctl server logs            # Show server logs (last 50 lines)
doh-ctl server follow          # Follow server logs in real-time
doh-ctl status                 # Show both services status
doh-ctl test                   # Test DNS resolution
doh-ctl config client          # Show client configuration
doh-ctl config server          # Show server configuration
doh-ctl resolve status         # Resolve subcommand
```

### doh-resolve - systemd-resolved Management
```bash
doh-resolve status      # Show current configuration
doh-resolve disable     # Free port 53 for DNS-over-HTTPS
doh-resolve enable      # Restore systemd-resolved
doh-resolve check       # Check port 53 usage
doh-resolve configure   # Interactive wizard
```

## Upgrade Behavior

The package intelligently handles upgrades:

- **Service Running**: Automatically restarts with new version
- **Service Stopped**: Remains stopped, respects your intent

Example:
```bash
# Service is running
sudo systemctl start doh-client

# Upgrade DNS-over-HTTPS
sudo apt upgrade dns-over-https
# Output: "doh-client service restarted successfully"

# Service was stopped
sudo systemctl stop doh-client

# Upgrade DNS-over-HTTPS
sudo apt upgrade dns-over-https
# Output: "Service remains stopped, start when ready: sudo systemctl start doh-client"
```

## Configuration

### Client Configuration
`/etc/dns-over-https/doh-client.conf` - Created during installation

Default upstream servers:
- Google DNS (dns.google)
- Cloudflare DNS (cloudflare-dns.com)

### Server Configuration
`/etc/dns-over-https/doh-server.conf` - Created during installation

Requires reverse proxy setup (Apache/Nginx/Caddy).

## Systemd Service Management

```bash
# View service status
systemctl status doh-client

# Enable auto-start
sudo systemctl enable doh-client

# Disable auto-start
sudo systemctl disable doh-client

# View logs
sudo journalctl -u doh-client

# Follow logs real-time
sudo journalctl -u doh-client -f

# View recent errors
sudo journalctl -u doh-client -n 50
```

## Logging

DNS-over-HTTPS logs to systemd journal:

```bash
# View all doh-client logs
sudo journalctl -u doh-client

# Follow in real-time
sudo journalctl -u doh-client -f

# Last 50 entries
sudo journalctl -u doh-client -n 50

# Or use doh-ctl
doh-ctl client logs       # Last 50 lines
doh-ctl client follow     # Real-time follow
```

## File Locations

```
/usr/local/bin/
  doh-client           # Client binary
  doh-server           # Server binary
  doh-ctl              # Service control utility
  doh-resolve          # systemd-resolved management

/etc/dns-over-https/
  doh-client.conf      # Client configuration
  doh-server.conf      # Server configuration
  nginx.example        # Nginx reverse proxy example
  apache.example       # Apache reverse proxy example
  caddy.example        # Caddy reverse proxy example

/etc/systemd/system/
  doh-client.service   # Client systemd service file
  doh-server.service   # Server systemd service file

/usr/share/man/man1/
  doh-ctl.1            # Man page for doh-ctl
  doh-resolve.1        # Man page for doh-resolve
```

## Troubleshooting

### Port 53 Already in Use
```bash
# Check what's using it
doh-resolve check

# Disable systemd-resolved
sudo doh-resolve disable

# Or use interactive wizard
sudo doh-resolve configure
```

### Service Won't Start
```bash
# Check status and errors
sudo systemctl status doh-client

# View detailed logs
sudo journalctl -u doh-client -n 100

# Test manually
sudo /usr/local/bin/doh-client -conf=/etc/dns-over-https/doh-client.conf
```

### DNS Resolution Not Working
```bash
# Check service is running
sudo systemctl status doh-client

# Test local DNS
dig @127.0.0.1

# Check for errors
doh-ctl client logs

# Verify configuration
doh-ctl config client
```

## Security Features

- **Unprivileged User**: Runs as unprivileged `doh` user
- **Capability Limiting**: Only `CAP_NET_BIND_SERVICE` capability for client
- **Secure Permissions**: Sensible defaults for all files
- **Configuration Protection**: Debian conffiles protect user configs

## Installation & Removal

### Install
```bash
sudo apt install ./dns-over-https-1.0.0-amd64.deb
```

### Remove (keep config)
```bash
sudo apt remove dns-over-https
```

### Remove (complete cleanup)
```bash
sudo apt purge dns-over-https
```

## Package Contents

- **2 Binaries**: doh-client, doh-server
- **2 CLI Utilities**: Service control, resolve management
- **3 System Scripts**: Installation, pre-removal, post-removal
- **5 Configuration Files**: Client/server configs, systemd files, examples
- **Documentation**: README, man pages, copyright

## Building the Package

### Prerequisites
```bash
# On Debian/Ubuntu
sudo apt install build-essential devscripts dpkg-dev golang git curl

# Or use the GitHub Actions workflow
```

### Build Locally
```bash
# Make build script executable
chmod +x build.sh

# Run build script
./build.sh
```

### Build with GitHub Actions
The package automatically builds on version changes:
1. Edit `deb_version` file
2. Commit and push to main branch
3. GitHub Actions builds for amd64, arm64, armv7
4. Creates GitHub release with all packages

## Help & Documentation

```bash
# View help for any utility
doh-ctl --help
doh-resolve --help

# Read man pages
man doh-ctl
man doh-resolve

# View installed configuration
cat /etc/dns-over-https/doh-client.conf
```

## Common Use Cases

### Use Case 1: Privacy-Focused DNS Client
```bash
# Install package
sudo apt install ./dns-over-https-1.0.0-amd64.deb

# Disable systemd-resolved
sudo doh-resolve disable

# Start client (uses Google/Cloudflare by default)
sudo systemctl start doh-client
sudo systemctl enable doh-client

# Test
dig @127.0.0.1 google.com
```

### Use Case 2: Custom Upstream DoH Servers
```bash
# Edit client configuration
sudo nano /etc/dns-over-https/doh-client.conf

# Change upstream servers to your preferred providers
# [[upstream]]
#     url = "https://your-doh-server.com/dns-query"
#     weight = 100

# Restart service
sudo doh-ctl client restart
```

### Use Case 3: Run Your Own DoH Server
```bash
# Configure server
sudo nano /etc/dns-over-https/doh-server.conf

# Set up reverse proxy (see examples in /etc/dns-over-https/)
sudo nano /etc/nginx/sites-available/doh
# Copy from /etc/dns-over-https/nginx.example

# Start server
sudo systemctl start doh-server
sudo systemctl enable doh-server
```

### Use Case 4: Split DNS (Internal + DoH)
```bash
# Edit client configuration
sudo nano /etc/dns-over-https/doh-client.conf

# Add passthrough for internal domains
# passthrough = [
#     "internal.company.com",
#     "lan",
# ]
#
# [passthrough_resolver]
#     address = "192.168.1.1"
#     port = 53

# Restart service
sudo doh-ctl client restart
```

## Support

For issues or questions:
- Check logs: `doh-ctl client logs`
- View man pages: `man doh-ctl`
- Upstream docs: https://github.com/m13253/dns-over-https
- Package issues: Create an issue in your repository

## License

See `/usr/share/doc/dns-over-https/copyright` for license information.

Upstream project is licensed under MIT License.