# syntax=docker/dockerfile:1
# Multi-stage build: dev target for dev containers, prod for deployment.

ARG PYTHON_VERSION=3.13

# ─── Base: Python + uv ────────────────────────────────────────────────────────
FROM ghcr.io/astral-sh/uv:python${PYTHON_VERSION}-bookworm-slim AS base

WORKDIR /app

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# ─── Dev: non-root user; uv auto-syncs on first `uv run` ─────────────────────
FROM base AS dev

RUN useradd --create-home --uid 1000 devuser \
    && mkdir -p /app/.venv \
    && chown -R devuser:devuser /app
USER devuser

COPY --chown=devuser:devuser pyproject.toml uv.lock* ./
COPY --chown=devuser:devuser . .

CMD ["uv", "run", "pytest"]

# ─── Builder: production deps only ────────────────────────────────────────────
FROM base AS builder

COPY pyproject.toml uv.lock* LICENSE ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --no-dev

COPY src/ ./src/

# ─── Production: minimal runtime image ────────────────────────────────────────
FROM python:${PYTHON_VERSION}-slim-bookworm AS prod

WORKDIR /app

COPY --from=builder /app/.venv /app/.venv
COPY --from=builder /app/src ./src

ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Run as non-root
RUN useradd --create-home appuser
USER appuser

CMD ["python", "-m", "app.main"]
