# Architecture

Protectorate Core is developed as a portable source tree.

Installation is the process of transforming the source tree
into the target system's runtime layout.

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
                   User
                    │
                    ▼
      bin/protectorate-login
                    │
                    ▼
          lib/bootstrap.sh
                    │
                    ▼
             Discover Project Root
                    │
                    ▼
               config.sh
                    │
        ┌───────────┼────────────┐
        ▼           ▼            ▼
     ui.sh      banner.sh    system.sh
                    │
                    ▼
                prompt.sh```

The shell initialization process is idempotent.

Each module is responsible for initializing only its own functionality.

---

## Directory Layout

```text
assets/      Static project assets
bin/         User-facing executables
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
- Avoid unnecessary side effects during import.
- Export functions instead of executing logic.
- Document its public interface.

Modules should primarily define reusable functions.
Configuration modules may export shared project constants.

Library modules must not:

- Rediscover the project root
- Source sibling modules directly
- Perform unnecessary initialization during import

Each module should assume the framework has already been initialized.

---

## Framework Initialization Order

Protectorate Core initializes in the following order:

1. An executable in `/bin` sources `lib/bootstrap.sh`.
2. `bootstrap.sh` discovers and exports `PROTECTORATE_ROOT`.
3. `config.sh` is loaded to establish project-wide configuration.
4. Remaining framework modules are loaded.
5. Control returns to the executable.

## Shell Initialization

`bootstrap.sh` is the entry point for Protectorate Core.

Its responsibilities are:

- Discover the project root.
- Export `PROTECTORATE_ROOT`.
- Validate the installation.
- Load framework modules.
- Establish the shared shell environment.

Library modules must not determine the project root
independently.

Project-wide constants and configuration are defined in config.sh
but must never rediscover the project root themselves.

---
## Node Discovery and State

Protectorate Core separates node configuration, discovery, persistent
registry state, and health data.

```text
       Administrator Configuration
                  │
                  ▼
              Discovery
                  │
                  ▼
        Persistent Node Registry
                  │
                  ▼
          Health Collection
                  │
                  ▼
            Health Cache
                  │
                  ▼
            Presentation

```

Administrator-defined configuration resides under
`/etc/protectorate/config`.

Persistent discovered node state resides under
`/var/lib/protectorate`.

Regenerable health data resides under
`/var/cache/protectorate`.

Discovery mechanisms populate a common node registry.

Health collection operates against the registry and does not depend
on the mechanism used to discover a node.

---

Core should remain focused on shared functionality rather than
absorbing unrelated features.
