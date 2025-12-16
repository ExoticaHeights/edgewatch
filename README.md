# EdgeWatch Core Runtime & UI Integration Guide
## Role: A – Runtime Services + UI Integration Engineer

This document describes the **core runtime services development approach** and **UI–backend integration responsibility** for the EdgeWatch project.

This role acts as the **technical bridge** between:
- Embedded system services
- Qt/QML UI layer

It combines **RTOS-style system thinking** with **embedded Linux userspace design**.

---

## 1. Role Definition

The Runtime + UI Integration role owns:
- Core system services
- Event-driven runtime behavior
- IPC API design
- Data exposure to the UI layer
- Consistency between backend state and UI state

**Interview-ready line:**
> “I designed core system services and acted as the integration bridge between runtime daemons and the Qt/QML UI.”

---

## 2. Scope of Responsibility

### In Scope
- Metrics collection service
- Configuration management service
- Health/heartbeat service
- IPC API definition
- Qt backend adapters and data models
- Runtime behavior guarantees

### Out of Scope
- BSP and bootloader
- UI screen design
- Networking protocol implementation

---

## 3. Runtime Architecture

```
System Services (C/C++)
        ↓
IPC APIs (DBus / UNIX sockets)
        ↓
Qt C++ Backend Adapters
        ↓
QML Models
        ↓
UI Screens
```

This architecture ensures:
- Clear separation of concerns
- Predictable data flow
- UI stability under failure

---

## 4. Core System Services

### 4.1 Metrics Service
Responsibilities:
- Collect CPU, memory, disk, and network stats
- Read from /proc and /sys
- Publish periodic updates

Example sources:
- /proc/stat
- /proc/meminfo
- /sys/class/net

---

### 4.2 Configuration Service
Responsibilities:
- Load and validate configuration
- Store persistent state
- Notify subscribers on change

Design rules:
- Config changes are atomic
- Invalid config never crashes system
- Defaults always available

---

### 4.3 Health & Heartbeat Service
Responsibilities:
- Track service liveness
- Publish system health state
- Detect degraded conditions

Health states:
- OK
- DEGRADED
- ERROR

---

## 5. IPC Design Strategy

### IPC Choices
- **DBus**: control, config, service discovery
- **UNIX sockets**: high-rate metrics streaming

### IPC Design Rules
- Versioned APIs
- Non-blocking calls
- Timeout handling
- Graceful failure behavior

Example DBus method:
```
GetSystemHealth() → string
```

---

## 6. UI Integration Strategy

### Key Responsibilities
- Convert raw system data into UI-friendly models
- Maintain consistent update rates
- Shield UI from backend failures

Qt backend example:
```cpp
Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
```

Rules:
- No heavy logic in QML
- UI never blocks on IPC
- Backend reconnection handled transparently

---

## 7. Event-Driven Design (RTOS → Linux)

RTOS principles applied:
- Deterministic behavior
- Event-driven logic
- Explicit state machines

Linux tools used:
- epoll
- timers
- signals

Avoid:
- Busy loops
- Blocking sleeps
- Global shared state

---

## 8. Error Handling & Resilience

Mandatory behaviors:
- Service restart does not break UI
- Partial data handled gracefully
- Errors logged, not fatal

Example:
- Metrics service down → UI shows degraded state
- Config error → fallback to defaults

---

## 9. Performance Constraints

Target limits:
- Low CPU usage (<5% idle)
- Stable memory usage
- Predictable update latency

Tools:
- top / htop
- valgrind
- perf

---

## 10. Logging & Observability

Logging rules:
- Startup sequence logs
- IPC connection logs
- Error paths always logged

Example:
```cpp
LOG_INFO("Metrics service started");
LOG_WARN("Config validation failed, using defaults");
```

---

## 11. Self-Validation (No Dedicated Testing Role)

The runtime engineer validates:
- Service restart robustness
- IPC timeout handling
- Memory leak absence
- UI consistency under failures

Interview line:
> “I validated runtime services by simulating failures and ensuring the UI remained responsive.”

---

## 12. Integration Points

### With UI Team (N)
- Data models
- Update frequencies
- UI state mapping

### With Runtime Orchestration (H)
- Startup order
- Health reporting
- Dependency handling

### With BSP (S)
- Filesystem paths
- Startup timing
- Resource constraints

---

## 13. Deliverables

This role delivers:
- Runtime daemons
- IPC API documentation
- Qt backend adapters
- System state definitions

---

## 14. Interview Summary

> “I implemented event-driven runtime services on embedded Linux, exposed clean IPC APIs, and integrated them into a Qt/QML UI while ensuring robustness and predictable behavior.”
