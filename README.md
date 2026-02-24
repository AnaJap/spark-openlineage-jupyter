# Spark + Jupyter + OpenLineage Starter

This repository provides a Dockerized Spark notebook environment with OpenLineage enabled, plus a local Marquez stack via Docker Compose.

## What is included

- `Dockerfile`: Jupyter all-spark image (`spark-3.5.3`) with OpenLineage Spark listener JAR installed.
- `spark-defaults.conf`: Spark listener + HTTP transport configuration for OpenLineage.
- `notebooks/OpenLineage_Spark_Demo.ipynb`: demo notebook to generate lineage events.
- `docker-compose.yml`: local stack with PostgreSQL, Marquez API, Marquez Web UI, and notebook container.

## Prerequisites

- Docker
- Docker Compose (v2, `docker compose`)

## Option 1: Run notebook only

Use this mode if you only want Jupyter/Spark.

```bash
docker build -t spark-ol-jupyter .
docker run --rm -p 8888:8888 spark-ol-jupyter
```

Open Jupyter at:

- `http://localhost:8888`

Notes:

- If no token is set at runtime, Jupyter may print an access URL with a token in container logs.
- `spark-defaults.conf` points OpenLineage transport to `http://marquez:5000`, so lineage delivery requires a reachable Marquez service.

## Option 2: Run full stack (recommended)

Use the provided compose file to run everything together:

```bash
docker compose up --build
```

Services:

- Jupyter notebook: `http://localhost:8888` (token: `token`)
- Marquez Web UI: `http://localhost:3000`
- Marquez API / OpenLineage endpoint: `http://localhost:5000`

To stop:

```bash
docker compose down
```

## OpenLineage listener version

Current Docker build args in `Dockerfile`:

- `OPENLINEAGE_SPARK_VERSION=1.44.0`
- `OPENLINEAGE_SPARK_SCALA_SUFFIX=_2.12`

If your Spark build expects Scala 2.13 artifacts, override during build:

```bash
docker build -t spark-ol-jupyter --build-arg OPENLINEAGE_SPARK_SCALA_SUFFIX=_2.13 .
```
