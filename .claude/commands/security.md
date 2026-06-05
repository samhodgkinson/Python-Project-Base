Run security scans: static analysis and dependency vulnerability checks.

```bash
uv run bandit -r src/ -c pyproject.toml
uv run pip-audit
```

Report any HIGH or MEDIUM severity findings with:
- What the issue is
- Where it occurs (file:line)
- Recommended fix
