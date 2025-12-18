# EdgeWatch BSP – QEMU Binary Release v0.1

## Included Artifacts
- Linux Kernel Image (ARM64, v6.12.0)
- Buildroot Root Filesystem (ext4)
- U-Boot binary for QEMU virt

## Notes
- This release contains **binaries only**
- Intended for QEMU `virt` ARM64 platform
- Boot scripts will be released separately

## Kernel Command Line (Reference)
console=ttyAMA0 root=/dev/vda rw earlycon=pl011,0x09000000

