#!/bin/bash
set -e

# ==========================================================
# EdgeWatch BSP - QEMU Launcher (v0.3 Qt Widgets Release)
# ==========================================================

REPO="ExoticaHeights/edgewatch"
RELEASE_TAG="v0.3-edgewatch-widgets"

WORKDIR="$HOME/edgewatch-qemu-v0.3"
BIN_DIR="$WORKDIR/binaries"

KERNEL_IMAGE="$BIN_DIR/Image"
ROOTFS_IMAGE="$BIN_DIR/rootfs.ext4"
UBOOT_BIN="$BIN_DIR/u-boot.bin"
SHA_FILE="$BIN_DIR/SHA256SUMS"

QEMU_RAM=1024
QEMU_CPU="cortex-a57"

BOOTARGS="console=ttyAMA0 root=/dev/vda rw earlycon=pl011,0x09000000"

# ----------------------------------------------------------
# Helpers
# ----------------------------------------------------------

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "ERROR: Required tool '$1' not found"
    exit 1
  }
}

download() {
  local file=$1
  local url="https://github.com/$REPO/releases/download/$RELEASE_TAG/$file"

  if [ ! -f "$BIN_DIR/$file" ]; then
    echo "Downloading $file"
    curl -L --fail "$url" -o "$BIN_DIR/$file"
  else
    echo "$file already exists"
  fi
}

# ----------------------------------------------------------
# Pre-flight checks
# ----------------------------------------------------------

need qemu-system-aarch64
need curl
need sha256sum

mkdir -p "$BIN_DIR"

# ----------------------------------------------------------
# Download artifacts
# ----------------------------------------------------------

download Image
download rootfs.ext4
download u-boot.bin
download SHA256SUMS

# ----------------------------------------------------------
# Verify checksums
# ----------------------------------------------------------

echo "Verifying checksums (boot-critical artifacts only)..."
cd "$BIN_DIR"

grep -E "Image|rootfs.ext4|u-boot.bin" SHA256SUMS | sha256sum -c -

# ----------------------------------------------------------
# Launch QEMU
# ----------------------------------------------------------

echo "Starting EdgeWatch v0.3 (Qt Widgets) on QEMU..."

exec qemu-system-aarch64 \
  -machine virt \
  -cpu "$QEMU_CPU" \
  -m "$QEMU_RAM" \
  -bios "$UBOOT_BIN" \
  -kernel "$KERNEL_IMAGE" \
  -append "$BOOTARGS" \
  -drive file="$ROOTFS_IMAGE",format=raw,if=virtio \
  -nographic

