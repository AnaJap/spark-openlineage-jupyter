# Spark + Jupyter + OpenLineage Starter

This repository provides a Dockerized Spark notebook environment with OpenLineage enabled, plus a local Marquez stack via Docker Compose.

## What is included

- `Dockerfile`: Jupyter all-spark image (`spark-3.5.3`) with the local OpenLineage Spark snapshot jar baked in and Oracle JDBC support added.
- `spark-defaults.conf`: Spark listener + HTTP transport configuration for OpenLineage.
- `log4j2.properties`: Spark Log4j 2 configuration with `org.apache.spark` logging at `DEBUG`.
- `notebooks/openlineage_spark_demo.ipynb`: demo notebook to generate lineage events.
- `docker-compose.yml`: local stack with PostgreSQL, Marquez API, Marquez Web UI, Oracle Free, and the notebook container.

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
- Oracle Free listener: `localhost:1521`

The first Oracle startup can take a couple of minutes while the database is initialized.

Spark logging inside the notebook container is configured through `log4j2.properties`, with `org.apache.spark` set to `DEBUG`. Rebuild the image after changing that file so the updated logging config is copied into `${SPARK_HOME}/conf`.

Notebook volume mount in compose mode:

- `./notebooks` on your host is mounted to `/home/jovyan/work/notebooks` in the container.
- Changes to notebooks persist on your host and are visible immediately in Jupyter.

To stop:

```bash
docker compose down
```

Oracle connection details inside the compose network:

- Host: `oracle`
- Port: `1521`
- Service name: `FREEPDB1`
- Username: `SPARK_APP`
- Password: `SparkApp123!`
- JDBC URL: `jdbc:oracle:thin:@oracle:1521/FREEPDB1`

Example Spark write + read:

```python
demo_df = spark.createDataFrame(
    [(1, "Ada"), (2, "Linus")],
    ["id", "name"],
)

(
    demo_df.write.format("jdbc")
    .option("url", "jdbc:oracle:thin:@oracle:1521/FREEPDB1")
    .option("dbtable", "SPARK_APP.LINEAGE_DEMO")
    .option("user", "SPARK_APP")
    .option("password", "SparkApp123!")
    .option("driver", "oracle.jdbc.OracleDriver")
    .mode("overwrite")
    .save()
)

oracle_df = (
    spark.read.format("jdbc")
    .option("url", "jdbc:oracle:thin:@oracle:1521/FREEPDB1")
    .option("dbtable", "SPARK_APP.LINEAGE_DEMO")
    .option("user", "SPARK_APP")
    .option("password", "SparkApp123!")
    .option("driver", "oracle.jdbc.OracleDriver")
    .load()
)
```

## OpenLineage listener version

Spark now uses the checked-in local OpenLineage Spark jar only:

- `openlineage-spark_2.12-1.46.0-SNAPSHOT.jar`

The notebook image also downloads the Oracle JDBC driver during build:

- `ojdbc11:23.26.1.0.0`
