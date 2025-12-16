# EdgeWatch Runtime Orchestration & System Services Guide
## Role: H – Runtime Orchestration & System Services Engineer

This document describes the **runtime orchestration, init flow, and system-level service coordination** responsibilities for the EdgeWatch project.

This role focuses on **how the system behaves at runtime**, ensuring that all services start correctly, recover from failures, and operate reliably on embedded Linux.

---

## 1. Role Definition

The Runtime Orchestration role owns:
- System init and startup sequencing
- Service dependency management
- Runtime health monitoring
- Failure detection and recovery
- Watchdog and reboot policy

**Interview-ready line:**
> “I owned system startup orchestration and runtime stability, ensuring all services start in the correct order and recover gracefully on failures.”

---

## 2. Scope of Responsibility

### In Scope
- Init system configuration
- Service startup order
- Runtime dependency handling
- Health monitoring integration
- Watchdog management
- Boot-time optimization

### Out of Scope
- BSP and bootloader
- UI implementation
- Application business logic
- Networking protocol logic

---

## 3. Runtime Architecture View

```
Kernel
  ↓
Init System (BusyBox / systemd)
  ↓
Core Runtime Services (A + H)
  ↓
Networking Services (R)
  ↓
Qt UI Application (N + A)
```

The orchestration layer ensures **predictable and repeatable system behavior**.

---

## 4. Init System Strategy

### Phase 1 (QEMU / Early Development)
- BusyBox init
- Simple, transparent boot scripts
- Easy debugging via shell

### Phase 2 (Optional / Later)
- systemd for advanced dependency management
- Parallel startup optimization

---

## 5. Startup Sequencing

### Desired Startup Order
1. Mount filesystems
2. Start logging
3. Start core runtime services
4. Start networking
5. Launch Qt UI

### Why Order Matters
- UI must not start before services
- Networking must be available before remote APIs
- Early failures must be visible

---

## 6. Service Management

### Service Design Rules
- Each service runs as a separate process
- Services must handle SIGTERM and SIGINT
- Services must restart cleanly

### Example BusyBox Init Script
```sh
#!/bin/sh
case "$1" in
  start)
    /usr/bin/metricsd &
    ;;
  stop)
    killall metricsd
    ;;
esac
```

---

## 7. Dependency Handling

Dependencies are managed by:
- Startup ordering
- Health signals from services
- Restart policies

Example:
- UI waits for backend availability
- Networking services restart without affecting UI

---

## 8. Health Monitoring Strategy

### Health Checks
- Process alive check
- IPC responsiveness
- Resource usage thresholds

### Health States
- OK
- DEGRADED
- ERROR

Health state is exposed to:
- UI
- Remote management (via R)

---

## 9. Watchdog Integration

### Purpose
- Recover from hangs
- Detect unrecoverable failures

### Strategy
- Use Linux watchdog framework
- Kick watchdog from a health daemon
- Reboot system on fatal failures

---

## 10. Boot-Time Optimization

Key focus areas:
- Reduce unnecessary service startup
- Avoid blocking scripts
- Parallelize where possible

Metrics:
- Time to login prompt
- Time to UI availability

---

## 11. Logging & Diagnostics

### Logging Responsibilities
- Log service start/stop
- Log failures and restarts
- Preserve logs across reboots if possible

### Tools
- syslog
- journald (if systemd)
- Persistent log storage

---

## 12. Failure Scenarios & Handling

Mandatory scenarios to handle:
- Service crash
- Service startup failure
- Network unavailable
- Partial system failure

Expected behavior:
- No system hang
- Clear error reporting
- Automatic recovery when possible

---

## 13. Self-Validation (No Dedicated Testing Role)

The runtime orchestration owner validates:
- Cold boot reliability
- Service restart behavior
- Watchdog effectiveness
- System recovery after failures

Interview line:
> “I validated runtime stability by simulating service crashes and ensuring the system recovered without user intervention.”

---

## 14. Integration Points

### With Runtime Services (A)
- Service startup requirements
- Health reporting interfaces

### With UI Team (N + A)
- UI startup timing
- Service availability signals

### With BSP (S)
- Init system selection
- Boot-time constraints
- Filesystem layout

---

## 15. Deliverables

This role delivers:
- Init scripts or service unit files
- Startup dependency documentation
- Health monitoring logic
- Watchdog configuration

---

## 16. Interview Summary

> “I managed system init and runtime orchestration on embedded Linux, ensuring correct startup sequencing, robust failure handling, and reliable long-running operation.”
