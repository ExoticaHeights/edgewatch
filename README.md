# EdgeWatch UI Development Guide
## Role: N – Embedded UI Engineering (Primary UI Owner)

This document describes the **detailed, implementation-focused UI development approach** for the EdgeWatch project.  
It is written for **embedded Qt/QML development on Linux**, targeting **QEMU first**, with future portability to real hardware.

---

## 1. UI Role Definition

The UI role is **not just screen design**.

The UI owner is responsible for:
- UI architecture
- State management
- UI ↔ backend IPC integration
- Startup lifecycle handling
- Performance on constrained embedded systems

**Interview-ready line:**
> “I owned the embedded Qt/QML HMI from architecture to runtime integration.”

---

## 2. UI Scope in EdgeWatch

### UI Responsibilities
- Display system health overview
- Show live CPU, memory, disk, and network metrics
- Indicate service and network status
- React to backend events
- Remain responsive under load

### Out of Scope
- Direct hardware access
- Business logic
- Networking protocol implementation

The UI is a **consumer of services**, not a controller.

---

## 3. UI Architecture

Recommended architecture:

```
QML Views
   ↑
QML Models / ViewModels
   ↑
Qt C++ Backend Adapters
   ↑
IPC (DBus / UNIX sockets)
   ↑
System Services (A + H)
```

This separation ensures:
- Clean responsibilities
- Testable components
- Interview-safe architecture explanation

---

## 4. Project Directory Structure

```
ui/
├── CMakeLists.txt
├── src/
│   ├── main.cpp
│   ├── backend/
│   │   ├── MetricsAdapter.cpp
│   │   ├── ServiceStatusAdapter.cpp
│   │   └── BackendManager.cpp
│   ├── models/
│   │   ├── MetricsModel.qml
│   │   └── ServiceModel.qml
│   └── utils/
│       └── Logger.cpp
├── qml/
│   ├── main.qml
│   ├── screens/
│   │   ├── Dashboard.qml
│   │   ├── Network.qml
│   │   └── About.qml
│   ├── components/
│   │   ├── MetricCard.qml
│   │   └── StatusIndicator.qml
│   └── theme/
│       ├── Colors.qml
│       └── Fonts.qml
└── assets/
```

---

## 5. UI Startup & Lifecycle

### Startup Flow
1. Linux boots
2. Backend services start
3. UI application launches
4. UI connects to IPC
5. Dashboard becomes active

UI must handle:
- Backend not ready
- Backend restart
- Partial data availability

Example logic:
```qml
if (!backendConnected) {
    showLoadingScreen()
} else {
    showDashboard()
}
```

---

## 6. IPC Integration Strategy

### IPC Choices
- **DBus**: service availability, configuration
- **UNIX sockets**: periodic metrics

### Rule
❌ Never use DBus directly in QML  
✅ Always wrap IPC in C++ backend adapters

Example:
```cpp
class MetricsAdapter : public QObject {
    Q_OBJECT
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
};
```

Expose to QML:
```cpp
qmlRegisterType<MetricsAdapter>("EdgeWatch", 1, 0, "MetricsAdapter");
```

---

## 7. UI State Management

Defined UI states:
- BOOTING
- RUNNING
- DEGRADED
- ERROR

Example:
```qml
states: [
    State { name: "RUNNING" },
    State { name: "ERROR" }
]
```

This prevents UI freezes and undefined behavior.

---

## 8. Performance Constraints

Target limits:
- RAM usage < 50 MB
- CPU usage < 5–10% idle
- No blocking calls on UI thread

Best practices:
- Use timers instead of polling loops
- Avoid JavaScript-heavy logic
- Prefer signals over polling
- Optimize ListModel usage

---

## 9. Embedded-Specific Optimizations

- Use Qt Quick Controls 2
- Disable unused Qt modules
- Avoid unnecessary animations
- Fixed resolution design (QEMU first)
- No dynamic font loading

Buildroot example:
```
BR2_PACKAGE_QT6BASE=y
BR2_PACKAGE_QT6DECLARATIVE=y
```

---

## 10. Error Handling & Feedback

UI must always show meaningful status:
- Backend disconnected → warning
- Network down → indicator
- Partial data → greyed metrics

Never allow:
- Blank screens
- Frozen UI

---

## 11. Logging & Debugging

### Logging
- Startup stages
- IPC connection status
- UI errors

Example:
```cpp
qInfo() << "UI started";
qWarning() << "Backend disconnected";
```

### Debugging Tools
- qmlscene
- QML Profiler
- strace (embedded)

---

## 12. Self-Validation Responsibilities

No separate testing role exists.

The UI owner validates:
- Reliable startup
- Backend reconnect handling
- Stable memory usage
- Correct handling of invalid data

Interview line:
> “I validated the UI under backend failure and recovery scenarios.”

---

## 13. Integration Points

### With A
- Data models
- IPC contracts
- Update rates

### With H
- Startup sequencing
- Service availability signals

### With S
- Display resolution
- QEMU input devices
- Init script integration

---

## 14. Final Deliverables

The UI owner should provide:
- UI architecture diagram
- QML component hierarchy
- IPC adapter code
- Performance metrics
- QEMU screenshots

---

## 15. Interview Summary

> “I designed and implemented an embedded Qt/QML HMI, integrated it with backend services via IPC, managed lifecycle and failure states, and optimized it for low-resource embedded Linux systems.”
