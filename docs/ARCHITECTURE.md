# Architecture

Protectorate Core is built as a collection of small, focused modules.

Every component has a single responsibility and should remain
independent whenever practical.

---

## Principles

- Documentation first
- Modular design
- Shared libraries
- Thin executable wrappers
- Explicit configuration
- Predictable behavior

---

## Architecture

```text
                 User Shell
                      │
                      ▼
      /etc/profile.d/protectorate.sh
                      │
                      ▼
             lib/shell-init.sh
                      │
      ┌───────────────┼───────────────┐
      ▼               ▼               ▼
   prompt.sh      aliases.sh    environment.sh
                      │
                      ▼
                   ui.sh
```

The shell initialization process is idempotent.

Each module is responsible for initializing only its own functionality.

---

## Directory Layout

```text
assets/      Static project assets
bin/         User-facing executables
config/      Configuration
docs/        Project documentation
lib/         Shared shell libraries
logos/       Branding assets
motd/        Login and MOTD resources
scripts/     Administrative scripts
templates/   Project templates
tests/       Test resources
```

Each directory has one clearly defined responsibility.

---

## Modules

Every module shall:

- Have one responsibility.
- Be created from `templates/module.sh`.
- Avoid side effects during import.
- Export functions instead of executing logic.
- Document its public interface.

---

## Shell Initialization

Interactive shells load Protectorate Core through
`lib/shell-init.sh`.

Initialization is guarded to prevent multiple executions within the
same shell session.

Each module is loaded once.

---

Core should remain focused on shared functionality rather than
absorbing unrelated features.
