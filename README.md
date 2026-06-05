# Python-Project-Base

A production-ready base template for Python projects. Includes Docker, dev
container, uv package management, linting, type checking, testing, and
GitHub Actions CI with security scanning.

## Stack

| Tool | Purpose |
|------|---------|
| [Python 3.13](https://docs.python.org/3.13/) | Language runtime |
| [uv](https://docs.astral.sh/uv/) | Package manager & virtual envs |
| [Ruff](https://docs.astral.sh/ruff/) | Linting & formatting |
| [Mypy](https://mypy.readthedocs.io/) | Static type checking |
| [Pytest](https://docs.pytest.org/) | Testing |
| [Bandit](https://bandit.readthedocs.io/) | Security static analysis |
| [pip-audit](https://pypi.org/project/pip-audit/) | Dependency vulnerability scanning |
| [Docker](https://docs.docker.com/) | Multi-stage container builds |

## Quick Start

### Local Development (with uv)

```bash
# Clone and set up
git clone https://github.com/samhodgkinson/Python-Project-Base.git
cd Python-Project-Base

# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install all dependencies and create .venv
uv sync --all-groups

# Run the app
uv run python -m app.main

# Run tests
uv run pytest
```

### VS Code Dev Container

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open the repository in VS Code
3. Click **"Reopen in Container"** when prompted (or via Command Palette)

The container builds from the `dev` Dockerfile target with all tools and
VS Code extensions pre-configured.

### Docker

```bash
# Run tests in the dev container
docker compose run --rm test

# Run the production app
docker compose up app

# Build production image only
docker build --target prod -t myapp:latest .
```

## Project Structure

```
.
├── src/
│   └── app/
│       ├── __init__.py
│       └── main.py          # Entry point
├── tests/
│   └── test_main.py
├── .devcontainer/
│   └── devcontainer.json    # VS Code dev container
├── .github/
│   └── workflows/
│       ├── ci.yml           # Lint, test, security, Docker build
│       └── codeql.yml       # CodeQL security analysis
├── .vscode/
│   ├── settings.json        # Editor settings
│   ├── extensions.json      # Recommended extensions
│   └── launch.json          # Debug configurations
├── Dockerfile               # Multi-stage: dev / prod
├── docker-compose.yml
└── pyproject.toml           # All config: uv, ruff, mypy, pytest, bandit
```

## Development Workflow

```bash
# Add a dependency
uv add requests

# Add a dev dependency
uv add --group dev pytest-asyncio

# Lint
uv run ruff check .

# Format
uv run ruff format .

# Type check
uv run mypy src/

# Security scan
uv run bandit -r src/ -c pyproject.toml
uv run pip-audit
```

Always commit `uv.lock` when dependencies change — it ensures reproducible
installs in CI and other environments.

## GitHub Actions

| Workflow | Triggers | Jobs |
|----------|----------|------|
| **CI** | push/PR to `main` | Lint, Test (with coverage), Security scan, Docker build |
| **CodeQL** | push/PR to `main`, weekly | Python security analysis |

## Using This as a Template

1. **Rename the package**: update `src/app/` to your package name and update
   `pyproject.toml` (`name`, `[tool.hatch.build.targets.wheel]`).
2. **Update dependencies**: add your runtime deps with `uv add <pkg>`.
3. **Write your code** in `src/<package>/`.
4. **Write tests** in `tests/`.
5. **Commit `uv.lock`**: run `uv lock` and commit the lock file.
6. **Push** — CI will run automatically.

## License

[GPL-3.0](LICENSE)
