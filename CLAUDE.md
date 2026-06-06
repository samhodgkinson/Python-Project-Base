# CLAUDE.md — AI Context for Python-Project-Base

This file gives Claude Code (and other AI tools) the context needed to work
effectively in this repository.

## Project Overview

A base template for Python applications. The primary workflow is **dev
container first** — developers open this in VS Code, click "Reopen in
Container", and have a fully working environment with no local Python setup.
Clone this repo and replace `src/app/` with your own code.

The template ships with:

- **Python 3.13** managed by [uv](https://docs.astral.sh/uv/)
- **Docker** — multi-stage build (`dev` for dev containers, `prod` for deployment)
- **Dev Container** — VS Code dev container using the `dev` Docker target; runs
  as non-root `devuser`, `.venv` is kept in a named volume separate from the
  workspace mount
- **Ruff** — linting and formatting (replaces flake8, isort, black); runs on save
- **Mypy** — strict static type checking; VS Code defers to the mypy extension
- **Pytest** — test runner; coverage flags are explicit, not in addopts
- **pip-audit** — dependency vulnerability scanning in CI
- **Bandit** — available locally for static security scanning
- **GitHub Actions** — CI (lint, test, pip-audit, Docker build) + CodeQL for SAST

## Repository Layout

```
.
├── src/app/          # Application source code
│   ├── __init__.py
│   └── main.py       # Entry point: python -m app.main
├── tests/            # Pytest tests (mirrors src/app/ structure)
├── .devcontainer/    # VS Code dev container config
├── .github/
│   └── workflows/
│       ├── ci.yml        # Lint, test, security, Docker build
│       └── codeql.yml    # GitHub CodeQL security analysis
├── .vscode/          # Editor settings, extensions, launch configs
├── Dockerfile        # Multi-stage: dev / builder / prod
├── docker-compose.yml
└── pyproject.toml    # All project config (uv, ruff, mypy, pytest, bandit)
```

## Common Commands

All commands run inside the dev container terminal or locally with uv installed.

```bash
# Install all dependencies (creates .venv)
uv sync --all-groups

# Run the app
uv run python -m app.main

# Run tests
uv run pytest

# Run tests with coverage (coverage is not on by default — add flags explicitly)
uv run pytest --cov=src --cov-report=term-missing

# Lint
uv run ruff check .

# Format
uv run ruff format .

# Type check
uv run mypy src/

# Security scan (static) — available locally, not run in CI (CodeQL covers SAST)
uv run bandit -r src/ -c pyproject.toml

# Dependency vulnerability scan
uv run pip-audit

# Add a runtime dependency
uv add <package>

# Add a dev-only dependency
uv add --group dev <package>
```

## Docker Commands

```bash
# Run tests in Docker (no local Python needed)
docker compose run --rm test

# Build and run the production container
docker compose up app

# Build production image directly
docker build --target prod -t myapp:latest .

# Build dev image
docker build --target dev -t myapp:dev .
```

## Dev Container

Open this repository in VS Code and select **"Reopen in Container"**. The
devcontainer builds from the `dev` Dockerfile target. On first open:

1. Docker builds the `dev` image (~1–2 min)
2. `postCreateCommand` runs `uv sync --all-groups` to populate `.venv`
3. All VS Code extensions install automatically (Ruff, Mypy, pytest, Docker)

The `.venv` lives in a named Docker volume (not the workspace mount) so it
persists across container rebuilds and doesn't appear in the host file system.

## Architecture Notes

- Source code lives under `src/app/` (src-layout) to prevent import ambiguity.
  `pythonpath = ["src"]` in pytest config means tests work without an editable
  install, but `uv sync` installs the project in editable mode regardless.
- `uv.lock` must be committed — it ensures reproducible installs across the dev
  container, CI, and any other environment.
- The builder stage uses a two-step sync: `--no-install-project` first (external
  deps, well-cached layer), then full `uv sync --no-dev` with source files
  present (hatchling needs README.md and LICENSE to build the wheel).
- The production image copies only `.venv` and `src/` from the builder stage,
  running as non-root `appuser`.
- CI drops bandit (CodeQL covers the same SAST categories with data-flow
  analysis). pip-audit handles dependency CVEs.

## Testing Conventions

- Test files mirror `src/` structure: `tests/test_<module>.py`
- Use `pytest.CaptureFixture`, `tmp_path`, and other built-in fixtures
- Type-annotate all test functions and fixtures
- Aim for 100% branch coverage on new code

## When Making Changes

1. Write tests first (or alongside) new code
2. Run `uv run ruff check . && uv run ruff format .` before committing
3. Run `uv run mypy src/` — fix all type errors
4. Run `uv run pytest` — all tests must pass
5. Commit `uv.lock` whenever dependencies change
