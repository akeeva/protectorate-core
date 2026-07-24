# Coding Standards

These standards exist to keep Protectorate Core consistent,
predictable, and maintainable.

---

## Philosophy

Write code that is easy to read.

Prefer clarity over cleverness.

Keep modules small and focused.

---

## Principles

- Simplicity before flexibility.
- Consistency before convenience.
- Explicit over implicit.
- Reuse before duplication.

---

## General

- Use Bash.
- Use four-space indentation.
- Quote variables unless expansion is intentional.
- Prefer functions over inline logic.
- Keep executable scripts thin.
- Place reusable code in `lib/`.

---

## Modules

Every module shall:

- Be created from `templates/module.sh`.
- Have one responsibility.
- Export a documented public interface.
- Avoid side effects during import.
- Document its public functions.

Only documented public functions should be called from outside the
module.

Private functions are internal implementation details and should not
be referenced by other modules.

---

## Naming

Use descriptive names.

Public functions:

```text
header_show()
system_collect()
protectorate_prompt()
```

Private functions:

```text
_initialize()
_load_config()
_render_banner()
```

Private functions shall begin with an underscore (`_`) and are
considered internal implementation details of the module.

Variables:

```text
PROTECTORATE_ROOT
PROTECTORATE_VERSION
UI_PRIMARY
```

Constants should use uppercase.

Public functions should use lowercase with underscores.

Private functions should begin with an underscore.

---

## Shell

- Prefer `readonly` for constants.
- Use `local` inside functions.
- Return status codes instead of exiting.
- Check command failures explicitly.
- Minimize global variables.

---

## Documentation

Wrap prose at approximately 72 characters.

Write for engineers.

Every sentence must earn its place.

Each document should have one purpose.

Avoid duplicated information.

Document architecture rather than implementation.

---

## Project Layout

Shared functionality belongs in `lib/`.

Executable entry points belong in `bin/`.

Administrative scripts belong in `scripts/`.

Templates belong in `templates/`.

Documentation belongs in `docs/`.

---

## Testing

New functionality should be tested before merging.

Bug fixes should include a regression test whenever practical.

Changes should not introduce ShellCheck warnings.
