Run linting, formatting, and type checks.

```bash
uv run ruff check . && uv run ruff format --check . && uv run mypy src/
```

If ruff reports errors, fix them. If mypy reports type errors, explain each
one and apply fixes. After fixing, re-run to confirm all checks pass.
