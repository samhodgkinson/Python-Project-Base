# Python Project Base

[![CI](https://github.com/samhodgkinson/Python-Project-Base/actions/workflows/ci.yml/badge.svg)](https://github.com/samhodgkinson/Python-Project-Base/actions/workflows/ci.yml)
[![CodeQL](https://github.com/samhodgkinson/Python-Project-Base/actions/workflows/codeql.yml/badge.svg)](https://github.com/samhodgkinson/Python-Project-Base/actions/workflows/codeql.yml)
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/samhodgkinson/Python-Project-Base?quickstart=1)

A ready-to-code Python template. Open in VS Code, click **Reopen in Container**, and you have a fully configured Python environment — no local Python installation required.

Everything is pre-wired: testing, linting, type checking, debugging, and CI that runs on every pull request.

## Getting started

### Local (VS Code + Docker)

**Prerequisites:** [VS Code](https://code.visualstudio.com/) · [Docker Desktop](https://www.docker.com/products/docker-desktop/) · [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

1. Click **Use this template** → **Create a new repository** on GitHub
2. Clone your new repository and open the folder in VS Code
3. VS Code will prompt **"Reopen in Container"** — click it
   - (Or: Command Palette → `Dev Containers: Reopen in Container`)
4. The container builds on first open (~1–2 min). Dependencies install automatically.
5. Open a terminal inside VS Code and run the tests to confirm everything works:

```bash
uv run pytest
```

You should see all tests pass. The environment is ready.

## Running tests

```bash
# Run tests
uv run pytest

# Run tests with a coverage report
uv run pytest --cov=src --cov-report=term-missing
```

The VS Code Testing panel (flask icon in the sidebar) also discovers and runs tests with a click.

## Writing code

Put your code in `src/app/` and tests in `tests/`. The editor is pre-configured to:

- **Format on save** — Ruff fixes style automatically when you save a file
- **Highlight type errors** — Mypy flags type problems as you type
- **Run tests** — from the Testing panel or the terminal
- **Debug** — F5 launches the debugger (see the pre-configured launch profiles in the Run panel)

## Adding dependencies

Inside the container terminal:

```bash
# Add a runtime dependency
uv add requests

# Add a dev-only dependency (testing tools, linters, etc.)
uv add --group dev pytest-asyncio

# Always commit the lock file after changing dependencies
git add uv.lock && git commit -m "Add requests"
```

The `uv.lock` file pins every dependency to an exact version so CI and other developers get identical environments.

## Using this as a base for a new project

1. **Rename the package** — move `src/app/` to `src/<your-package>/` and update `pyproject.toml`:

   ```toml
   [project]
   name = "your-project"

   [tool.hatch.build.targets.wheel]
   packages = ["src/your-package"]
   ```

2. **Replace the example code** in `src/<your-package>/main.py` with your own

3. **Write tests** in `tests/test_<module>.py` mirroring your source layout

4. **Push** — CI runs automatically on every pull request

## CI — what runs on every pull request

| Check | What it does |
|-------|-------------|
| Lint & Format | Ruff checks code style |
| Type check | Mypy strict mode |
| Tests | pytest with coverage |
| Security | pip-audit scans dependencies for known vulnerabilities |
| Docker build | Builds both the dev and production images |
| CodeQL | GitHub's security analysis (also runs weekly) |

Set up **branch protection rules** on `main` (GitHub → Settings → Branches) to require all checks to pass before a PR can be merged.

## Production Docker image

The `Dockerfile` has two targets:

- **`dev`** — used by the dev container and `docker compose run --rm test`
- **`prod`** — a minimal image with only runtime dependencies, running as a non-root user

```bash
# Run the test suite in Docker (no local setup needed)
docker compose run --rm test

# Build and run the production image
docker build --target prod -t myapp:latest .
docker run myapp:latest
```

## Project layout

```
src/app/            ← application source code (rename app/ to your package name)
tests/              ← tests (mirror src/ structure)
.devcontainer/      ← VS Code dev container config
.github/workflows/  ← CI pipelines (ci.yml, codeql.yml)
.vscode/            ← editor settings, extensions, debug configs
Dockerfile          ← dev and production images
docker-compose.yml  ← test and app services
pyproject.toml      ← all project config (uv, ruff, mypy, pytest)
uv.lock             ← locked dependencies — always commit this
```

## License

[GPL-3.0](LICENSE)
