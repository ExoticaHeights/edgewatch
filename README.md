# EdgeWatch
## Embedded Linux Edge Monitoring Gateway (QEMU → Real Hardware)

EdgeWatch is a **team-built, production-style embedded Linux project** designed to demonstrate **end-to-end system ownership**, from BSP bring-up to UI and networking.

The project is developed **QEMU-first** and later portable to **real embedded hardware**, following industry-grade workflows and practices.

---

## 1. Project Overview

**EdgeWatch** is an embedded Linux gateway that:
- Boots via custom BSP (U-Boot + Linux + Buildroot)
- Collects system and network metrics
- Exposes data locally via a Qt/QML UI
- Exposes data remotely via REST, WebSocket, and SNMP
- Handles failures gracefully
- Is portable across hardware platforms

This project is intentionally scoped to be:
- Simple enough to complete
- Deep enough for technical interviews
- Realistic for embedded product teams

---

## 2. Key Features

- QEMU ARM64 virtual platform
- Custom Linux BSP (U-Boot, kernel, rootfs)
- Event-driven runtime services
- Embedded Qt/QML dashboard
- REST & WebSocket APIs
- SNMP monitoring support
- Developer-owned validation (no separate QA role)
- Clear migration path to real hardware

---

## 3. System Architecture (High Level)

```
Remote Clients / NMS
        ↓
REST / WebSocket / SNMP
        ↓
Networking Services (R)
        ↓
IPC (DBus / UNIX sockets)
        ↓
Core Runtime Services (A + H)
        ↓
Qt/QML UI (N + A)
        ↓
Linux Kernel
        ↓
U-Boot
        ↓
QEMU / Real Hardware
```

---

## 4. Boot Flow

```
QEMU Loader / ROM
        ↓
U-Boot
        ↓
Linux Kernel + DTB
        ↓
init (BusyBox / systemd)
        ↓
Runtime Services
        ↓
Qt UI Application
```

---

## 5. Repository Structure

```
edgewatch/
├── bsp/                 # BSP, bootloader, kernel configs
├── buildroot/           # Root filesystem configuration
├── services/            # Runtime services & orchestration
├── ui/                  # Qt/QML embedded UI
├── networking/          # REST, WebSocket, SNMP services
├── docs/                # Design & role READMEs
├── .github/workflows/   # CI & email notifications
└── README.md            # This file
```

---

## 6. Team Structure & Ownership Model

This project follows a **clear ownership model with controlled collaboration**.

### Team Mapping

- **S** → Platform & BSP (separate)
- **N + A** → Embedded UI & Application
- **A + H** → Core Runtime & System Services
- **R** → Networking & Remote Management (separate)

> A acts as a **bridge engineer** between UI and runtime services.

### Ownership Principles
- Each member owns design, implementation, and self-validation
- No dedicated testing role in early stages
- Integration and debugging are shared

---

## 7. Git Workflow

- `main`  
  - Stable, release-ready  
  - Only **S** can merge

- `develop`  
  - Integration branch  
  - Feature branches merge here

- `feature/*`  
  - Created by anyone  
  - Merged into `develop`

Branch protection and email notifications are enforced via GitHub Actions.

---

## 8. Development Platform

- Host OS: Ubuntu Linux
- Target: QEMU ARM64 (`virt`)
- Toolchain: Buildroot
- UI: Qt 6 / QML
- IPC: DBus, UNIX sockets

---

## 9. CI / Automation

GitHub Actions are used for:
- PR merge notifications (email)
- Build checks (optional)
- Workflow enforcement

This ensures team-wide visibility without manual monitoring.

---

## 10. Porting to Real Hardware

The system is designed to be portable by:
- Isolating hardware differences in:
  - Device Tree
  - Bootloader configuration
- Keeping userspace unchanged

Candidate boards:
- TI AM62x
- NXP i.MX8
- Raspberry Pi

---

## 11. Documentation Index

- BSP Guide → `bsp/README.md`
- UI Guide (N) → `ui/README.md`
- Runtime + UI Integration (A) → `services/README-runtime-ui.md`
- Runtime Orchestration (H) → `services/README-orchestration.md`
- Networking (R) → `networking/README.md`

---

## 12. Interview-Ready Summary

> “EdgeWatch is a QEMU-first embedded Linux gateway built with clear subsystem ownership, realistic boot and runtime design, and clean separation between BSP, services, UI, and networking.”

This project demonstrates:
- Embedded Linux fundamentals
- System design thinking
- Cross-team collaboration
- Production-style workflows

---

## 13. Getting Started (High Level)

```bash
git clone <repo>
cd edgewatch
# Follow bsp/README.md to build and boot in QEMU
```

---

## 14. License

To be added (MIT / Apache 2.0 recommended).
