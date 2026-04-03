FROM quay.io/jupyter/all-spark-notebook:spark-3.5.3

USER root

# Install curl for fetching runtime JARs
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ---- Local OpenLineage Spark runtime ----
COPY openlineage-spark_2.12-1.46.0-SNAPSHOT.jar \
    ${SPARK_HOME}/jars/openlineage-spark_2.12-1.46.0-SNAPSHOT.jar

# ---- Oracle JDBC driver for Spark JDBC reads/writes ----
ARG ORACLE_JDBC_VERSION=23.26.1.0.0
RUN curl -fsSL \
    "https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc11/${ORACLE_JDBC_VERSION}/ojdbc11-${ORACLE_JDBC_VERSION}.jar" \
    -o "${SPARK_HOME}/jars/ojdbc11-${ORACLE_JDBC_VERSION}.jar"

# Spark defaults (enables the listener + sets HTTP transport)
COPY spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf
COPY log4j2.properties ${SPARK_HOME}/conf/log4j2.properties

# Permissions for jovyan user
RUN chown ${NB_UID}:${NB_GID} \
    ${SPARK_HOME}/conf/spark-defaults.conf \
    ${SPARK_HOME}/conf/log4j2.properties \
    ${SPARK_HOME}/jars/openlineage-spark_2.12-1.46.0-SNAPSHOT.jar \
    ${SPARK_HOME}/jars/ojdbc11-${ORACLE_JDBC_VERSION}.jar

USER ${NB_UID}

EXPOSE 8888
