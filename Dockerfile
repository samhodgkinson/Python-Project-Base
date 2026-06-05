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

# ─── Dev: all deps including dev tools ────────────────────────────────────────
FROM base AS dev

COPY pyproject.toml uv.lock* ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --all-groups

COPY . .

CMD ["uv", "run", "pytest"]

# ─── Builder: production deps only ────────────────────────────────────────────
FROM base AS builder

COPY pyproject.toml uv.lock* ./
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
