# Architectural Decisions

This document records significant architectural decisions made during
the development of Protectorate Core.

Each decision captures the reasoning behind the change to provide
historical context for future development.

---

## ADR-0001

### Title

Project Name

### Status

Accepted

### Decision

Rename the project from **ProtectorateOS** to **Protectorate Core**.

### Rationale

The project is not an operating system.

It provides a common operational foundation for Linux systems and
serves as the foundation of the Protectorate ecosystem.

The new name more accurately reflects its purpose while allowing the
Protectorate brand to expand into additional projects.

---

## ADR-0002

### Title

Installation Root

### Status

Accepted

### Decision

Install Protectorate Core under `/opt/protectorate`.

### Rationale

The current repository represents the foundation of the Protectorate
ecosystem.

Keeping all project assets beneath a single directory provides a
stable location while allowing future expansion.

---

## ADR-0003

### Title

Modular Architecture

### Status

Accepted

### Decision

Build Protectorate Core as a collection of small modules.

### Rationale

Small modules are easier to understand, test, and maintain.

Shared functionality belongs in reusable libraries rather than
duplicated across scripts.

---

## ADR-0004

### Title

Documentation Style

### Status

Accepted

### Decision

Documentation shall be concise and written for engineers.

### Rationale

Documentation should reflect the design philosophy of the project.

Every sentence should contribute useful information.

Each document should have a single purpose.

---

## ADR-0005

### Title

Public and Private Functions

### Status

Accepted

### Decision

Private functions shall begin with an underscore (`_`).

Only documented public functions form the module interface.

### Rationale

Clear public interfaces improve maintainability.

Private implementation details should remain encapsulated within each
module.
