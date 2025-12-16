# EdgeWatch BSP & Platform Development Guide
## Role: S – Platform & BSP Engineering (System Foundation Owner)

This document describes the **end-to-end BSP and platform development approach** for the EdgeWatch project.  
It covers **QEMU-first bring-up**, Linux boot flow, Buildroot integration, and **future migration to real hardware**.

This role represents **full system ownership**, from power-on to application startup.

---

## 1. BSP Role Definition

The BSP owner is responsible for:
- System boot reliability
- Kernel and root filesystem integration
- Hardware abstraction
- QEMU to real hardware portability
- Release-quality system images

**Interview-ready line:**
> “I owned the full embedded Linux BSP, from U-Boot and kernel bring-up to rootfs integration and application startup.”

---

## 2. Platform Scope

### In Scope
- QEMU ARM64 bring-up
- U-Boot configuration
- Linux kernel configuration
- Device tree management
- Buildroot-based root filesystem
- Boot-time optimization
- Hardware migration planning

### Out of Scope
- Application business logic
- UI implementation
- Networking protocol logic

---

## 3. Target Platforms

### Phase 1 – Virtual Platform
- QEMU `virt` (ARM64)
- VirtIO devices
- Serial console

### Phase 2 – Real Hardware (Future)
- TI AM62x / i.MX8 / Raspberry Pi (example)
- eMMC / SD boot
- Ethernet, display, watchdog

---

## 4. Boot Flow Architecture

```
QEMU Loader / SoC ROM
        ↓
      U-Boot
        ↓
Linux Kernel + DTB
        ↓
       init
        ↓
  System Services
        ↓
   Qt UI Application
```

The BSP ensures **deterministic, debuggable boot** at every stage.

---

## 5. U-Boot Development Approach

### Responsibilities
- Board configuration
- Boot command setup
- Kernel, DTB, rootfs loading
- Environment variables

### Example Boot Command
```bash
setenv bootargs console=ttyAMA0 root=/dev/vda rw
booti ${kernel_addr_r} - ${fdt_addr_r}
```

### Validation
- Serial console output
- Environment persistence
- Cold boot behavior

---

## 6. Linux Kernel Configuration

### Kernel Features Enabled
- ARM64 architecture
- PREEMPT scheduling
- VirtIO (block, net, console)
- Networking stack
- Watchdog framework
- tmpfs, overlayfs

### Configuration Strategy
- Start minimal
- Enable only required drivers
- Avoid board-specific code early

### Validation
- Clean boot without warnings
- Stable uptime
- Correct `/proc` and `/sys` entries

---

## 7. Device Tree Strategy

### QEMU Phase
- Use `virt.dtb`
- Minimal device descriptions
- Avoid custom bindings

### Hardware Phase
- Board-specific DTS
- Isolate changes to DTS only
- Reuse kernel and rootfs

---

## 8. Root Filesystem (Buildroot)

### Buildroot Responsibilities
- Toolchain selection
- BusyBox configuration
- Qt runtime support
- Application integration
- Filesystem layout

### Filesystem Layout
```
/
├── bin/
├── sbin/
├── lib/
├── etc/
│   └── edgewatch/
├── usr/
│   └── bin/
├── var/
│   └── log/
└── data/   (persistent)
```

### Key Buildroot Options
```
BR2_aarch64=y
BR2_PACKAGE_BUSYBOX=y
BR2_PACKAGE_QT6BASE=y
```

---

## 9. Init & Startup Strategy

### Init System
- BusyBox init (initial)
- systemd optional later

### Startup Order
1. Mount filesystems
2. Start core services (A + H)
3. Start networking
4. Launch Qt UI

### BSP Responsibility
- Correct ordering
- Failure handling
- Fast boot time

---

## 10. Hardware Abstraction & Portability

### Principles
- No board-specific logic in applications
- Hardware differences isolated to:
  - Device tree
  - Bootloader config
- Userspace remains unchanged

### Porting Checklist
- New DTS
- New boot media
- Verify peripherals
- Validate performance

---

## 11. Debugging & Diagnostics

### Tools Used
- QEMU serial console
- Kernel boot logs
- Early printk
- init shell
- gdb (kernel/userspace)

### Common Debug Scenarios
- Kernel panic
- Rootfs mount failure
- Init not launching apps
- Missing drivers

---

## 12. BSP Self-Validation (No Separate Testing Role)

The BSP owner validates:
- Reboot reliability
- Power-cycle behavior
- Boot-time consistency
- Rootfs integrity
- Application auto-start

Interview line:
> “I validated the BSP by repeated cold boots, failure injection, and boot-time analysis.”

---

## 13. Integration Points

### With UI Team (N + A)
- Display resolution
- Input devices
- UI startup timing

### With Runtime Services (A + H)
- Init ordering
- IPC availability
- Persistent storage paths

### With Networking (R)
- Network interface availability
- Firewall defaults

---

## 14. Deliverables

The BSP owner provides:
- Bootable QEMU image
- Buildroot configuration
- Kernel config
- Boot documentation
- Hardware porting guide

---

## 15. Interview Summary

> “I designed and owned the full embedded Linux BSP, including QEMU bring-up, U-Boot boot flow, kernel configuration, root filesystem integration, and a clear migration path to real hardware.”
