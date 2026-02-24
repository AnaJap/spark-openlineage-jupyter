# Spark + Jupyter + OpenLineage (Docker)

This folder contains a Dockerfile that runs:
- JupyterLab / Notebook (via Jupyter Docker Stacks)
- Apache Spark (already included in the base image)
- OpenLineage Spark listener jar preinstalled + enabled via spark-defaults.conf
- An example notebook that reads a CSV and writes Parquet (to trigger lineage)

## Build

```bash
docker build -t spark-ol-jupyter .
```

## Run (Jupyter only)

```bash
docker run --rm -p 8888:8888 spark-ol-jupyter
```

Open the URL printed in the logs.

> Lineage events are configured to be sent to `http://marquez:5000` by default.
> If you're not running Marquez, either change `spark-defaults.conf` or run with docker-compose (below).

## Run with Marquez (recommended)

Create a `docker-compose.yml` like this:

```yaml
services:
  marquez:
    image: marquezproject/marquez:latest
    ports:
      - "3000:3000"   # Marquez web UI
      - "5000:5000"   # Marquez OpenLineage/HTTP API
      - "5001:5001"   # Admin endpoints
    environment:
      - MARQUEZ_PORT=5000
    depends_on:
      - postgres
  postgres:
    image: postgres:14
    environment:
      - POSTGRES_USER=marquez
      - POSTGRES_PASSWORD=marquez
      - POSTGRES_DB=marquez
    ports:
      - "5432:5432"
  notebook:
    build: .
    ports:
      - "8888:8888"
    depends_on:
      - marquez
```

Then:

```bash
docker compose up --build
```

- Jupyter: http://localhost:8888
- Marquez UI: http://localhost:3000

## Notes

- If your Spark distribution uses Scala 2.13, build with:
  `--build-arg OPENLINEAGE_SPARK_SCALA_SUFFIX=_2.13`
