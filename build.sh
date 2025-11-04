#!/bin/bash
# Local build script for DNS-over-HTTPS Debian package
set -e

echo "===================================="
echo "DNS-over-HTTPS Package Builder"
echo "===================================="
echo ""

# Check if we're in the right directory
if [ ! -f "deb_version" ] || [ ! -d "pkg/DEBIAN" ]; then
    echo "Error: Must run from doh-deb directory"
    exit 1
fi

# Read version
DEB_VERSION=$(cat deb_version)
echo "Building package version: $DEB_VERSION"

# Detect architecture
ARCH=$(dpkg --print-architecture)
echo "Architecture: $ARCH"

# Check for Go
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed"
    echo "Install with: sudo apt install golang"
    exit 1
fi

GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
echo "Go version: $GO_VERSION"

# Clone and build DNS-over-HTTPS
echo ""
echo "Cloning DNS-over-HTTPS repository..."
if [ -d "dns-over-https" ]; then
    rm -rf dns-over-https
fi

# Get latest version
DOH_VERSION=$(curl -s https://api.github.com/repos/m13253/dns-over-https/releases/latest | grep tag_name | cut -d'"' -f4 | sed 's/^v//')
echo "DNS-over-HTTPS version: $DOH_VERSION"

git clone --depth 1 --branch v${DOH_VERSION} https://github.com/m13253/dns-over-https.git

# Build client
echo ""
echo "Building doh-client..."
cd dns-over-https/doh-client
go build -ldflags="-s -w"
cd ../..

# Build server
echo ""
echo "Building doh-server..."
cd dns-over-https/doh-server
go build -ldflags="-s -w"
cd ../..

# Copy binaries
echo ""
echo "Copying binaries to package..."
mkdir -p pkg/usr/local/bin
cp dns-over-https/doh-client/doh-client pkg/usr/local/bin/
cp dns-over-https/doh-server/doh-server pkg/usr/local/bin/
chmod 755 pkg/usr/local/bin/doh-client
chmod 755 pkg/usr/local/bin/doh-server

# Verify binaries
echo ""
echo "Binary info:"
ls -lh pkg/usr/local/bin/doh-*
file pkg/usr/local/bin/doh-client
file pkg/usr/local/bin/doh-server

# Set permissions
echo ""
echo "Setting permissions..."
chmod 755 pkg/DEBIAN/postinst
chmod 755 pkg/DEBIAN/prerm
chmod 755 pkg/DEBIAN/postrm
chmod 755 pkg/usr/local/bin/doh-ctl
chmod 755 pkg/usr/local/bin/doh-resolve
chmod 644 pkg/DEBIAN/control

# Update version in control file
sed -i "s/^Version: .*/Version: ${DEB_VERSION}/" pkg/DEBIAN/control
sed -i "s/Architecture: .*/Architecture: ${ARCH}/" pkg/DEBIAN/control

# Build package
echo ""
echo "Building Debian package..."
PKG_NAME="dns-over-https_${DEB_VERSION}_${ARCH}.deb"
dpkg-deb --build pkg "$PKG_NAME"

# Verify package
if [ ! -f "$PKG_NAME" ]; then
    echo "Error: Failed to create package"
    exit 1
fi

echo ""
echo "===================================="
echo "Package created successfully!"
echo "===================================="
echo ""
ls -lh "$PKG_NAME"
echo ""

# Show package info
echo "Package information:"
dpkg -I "$PKG_NAME"

echo ""
echo "Package contents (first 30 files):"
dpkg -c "$PKG_NAME" | head -30

# Cleanup
echo ""
read -p "Remove build directory? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf dns-over-https
    echo "Build directory removed"
fi

echo ""
echo "To install: sudo apt install ./$PKG_NAME"
echo "To test: dpkg -c $PKG_NAME"
