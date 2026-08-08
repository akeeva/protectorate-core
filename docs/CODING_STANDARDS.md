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


### Function Documentation

Every public function shall have a documentation block immediately
above its definition.

Non-trivial private functions shall also be documented. Private
functions are considered non-trivial when they implement policy,
parsing, validation, state management, fallback behavior, error
handling, or other behavior that is not obvious from the function
name and implementation.

Public function documentation should describe, where applicable:

- Purpose.
- Arguments.
- Output.
- Return status.
- Side effects.
- Important policy or behavioral constraints.

Private function documentation should describe:

- Purpose.
- Arguments when they are not obvious.
- Important behavior or implementation policy.

Comments should explain intent, constraints, or decisions rather than
simply restating the code.

Documentation is part of the implementation. Comments that become
inaccurate when behavior changes shall be updated with the code.

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
