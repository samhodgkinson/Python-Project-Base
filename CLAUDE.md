# CLAUDE.md — AI Context for Python-Project-Base

This file gives Claude Code (and other AI tools) the context needed to work
effectively in this repository.

## Project Overview

A base template for Python applications. Clone this repo and replace
`app/` with your own code. The template ships with:

- **Python 3.13** managed by [uv](https://docs.astral.sh/uv/)
- **Docker** — multi-stage build (`dev` for development, `prod` for deployment)
- **Dev Container** — VS Code dev container using the `dev` Docker target
- **Ruff** — linting and formatting (replaces flake8, isort, black)
- **Mypy** — strict static type checking
- **Pytest** — test runner with coverage
- **pip-audit** — dependency vulnerability scanning (CI); **Bandit** available locally
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

# Security scan (static)
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
# Build and run production container
docker compose up app

# Run tests inside dev container
docker compose run --rm test

# Build production image directly
docker build --target prod -t myapp:latest .

# Build dev image
docker build --target dev -t myapp:dev .
```

## Dev Container

Open this repository in VS Code and select **"Reopen in Container"**. The
devcontainer builds from the `dev` Dockerfile target, installs all
dependencies, and configures extensions automatically.

## Architecture Notes

- Source code lives under `src/app/` (src-layout) to prevent import ambiguity
  between installed packages and local source.
- `uv.lock` should be committed — it ensures reproducible installs across
  environments and in CI.
- The production Docker image copies only `.venv` and `src/` from the builder
  stage, keeping the final image small and without build tooling.
- Non-root user (`appuser`) is used in the production container; `devuser` in the dev container.

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
