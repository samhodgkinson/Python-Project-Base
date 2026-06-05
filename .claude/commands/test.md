Run the full test suite with coverage.

```bash
uv run pytest --cov=src --cov-report=term-missing -v
```

If tests fail, show the full traceback and suggest fixes. If coverage drops
below 80%, flag which lines are uncovered.
