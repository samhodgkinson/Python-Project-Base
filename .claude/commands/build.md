Build both Docker images (dev and prod) and verify they build cleanly.

```bash
docker build --target dev -t python-project-base:dev . && \
docker build --target prod -t python-project-base:prod .
```

Report image sizes for both targets. Flag any build warnings or errors.
