FROM quay.io/jupyter/all-spark-notebook:spark-3.5.3

USER root

# Install curl for fetching the OpenLineage Spark listener JAR
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ---- OpenLineage Spark listener ----
# NOTE:
# - most Spark 3.x distributions in Jupyter stacks use Scala 2.12
# - if your Spark uses Scala 2.13, change artifact to openlineage-spark_2.13
ARG OPENLINEAGE_SPARK_SCALA_SUFFIX=_2.12
ARG OPENLINEAGE_SPARK_VERSION=1.44.0

RUN curl -fsSL \
    "https://repo1.maven.org/maven2/io/openlineage/openlineage-spark${OPENLINEAGE_SPARK_SCALA_SUFFIX}/${OPENLINEAGE_SPARK_VERSION}/openlineage-spark${OPENLINEAGE_SPARK_SCALA_SUFFIX}-${OPENLINEAGE_SPARK_VERSION}.jar" \
    -o "${SPARK_HOME}/jars/openlineage-spark${OPENLINEAGE_SPARK_SCALA_SUFFIX}-${OPENLINEAGE_SPARK_VERSION}.jar"

# Spark defaults (enables the listener + sets HTTP transport)
COPY spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf

# Example notebook
COPY notebooks/ /home/jovyan/work/notebooks/

# Permissions for jovyan user
RUN chown -R ${NB_UID}:${NB_GID} ${SPARK_HOME}/conf/spark-defaults.conf /home/jovyan/work/notebooks

USER ${NB_UID}

EXPOSE 8888
