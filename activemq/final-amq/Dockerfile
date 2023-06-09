# FROM eclipse-temurin:11-jre-jammy
FROM eclipse-temurin:11-jre-jammy

ENV ACTIVEMQ_VERSION=5.18.1 MSSQL_JDBC_VERSION=12.2.0 MSSQL_JDBC_JRE_VERSION=11
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_HOME="/opt/activemq" \ 
    PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/activemq/bin/linux-x86-64/:/opt/java/openjdk/bin"

COPY entrypoint.sh conf/activemq.xml conf/sql.xml conf/broker.properties conf/credentials.properties /
WORKDIR /tmp

ADD https://www.apache.org/dyn/closer.cgi\?filename\=/activemq/$ACTIVEMQ_VERSION/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz\&action\=download apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz
ADD https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/${MSSQL_JDBC_VERSION}.jre${MSSQL_JDBC_JRE_VERSION}/mssql-jdbc-${MSSQL_JDBC_VERSION}.jre${MSSQL_JDBC_JRE_VERSION}.jar mssql-jdbc-${MSSQL_JDBC_VERSION}.jre${MSSQL_JDBC_JRE_VERSION}.jar

RUN mkdir -p /opt/activemq && \
    tar -xvf apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz && \
    mv $ACTIVEMQ/* ${ACTIVEMQ_HOME} &&\
    mv mssql-jdbc-${MSSQL_JDBC_VERSION}.jre${MSSQL_JDBC_JRE_VERSION}.jar ${ACTIVEMQ_HOME}/lib/optional/ &&\
    groupadd activemq && \
    useradd -s /bin/bash -g activemq -d $ACTIVEMQ_HOME activemq && \
    rm $ACTIVEMQ_HOME/conf/activemq.xml && \
    rm $ACTIVEMQ_HOME/conf/credentials.properties && \
    mv /activemq.xml ${ACTIVEMQ_HOME}/conf && \
    mv /sql.xml ${ACTIVEMQ_HOME}/conf && \
    mv /credentials.properties ${ACTIVEMQ_HOME}/conf && \
    mv /broker.properties ${ACTIVEMQ_HOME}/conf && \
    chown -R activemq:activemq $ACTIVEMQ_HOME && \
    chmod 777 /entrypoint.sh 
    
WORKDIR ${ACTIVEMQ_HOME}

EXPOSE 61616 8161

USER activemq

ENV ACTIVEMQ_SQL_DATASTORE=false ACTIVEMQ_SQL_JDBC_CONNECTION_STRING="" ACTIVEMQ_SQL_HOSTNAME="" \ 
    ACTIVEMQ_SQL_DATABASE="" ACTIVEMQ_SQL_PORT=1433 ACTIVEMQ_SQL_USERNAME="" ACTIVEMQ_SQL_PASSWORD="" \ 
    ACTIVEMQ_BROKER_NAME="activemq-on-docker" ACTIVEMQ_DATA_DIR="/opt/activemq/data" ACTIVEMQ_DATA_DIR_SIZE="100" \
    ACTIVEMQ_DATA_TMP_SIZE="50" ACTIVEMQ_OPENWIRE_PORT="61616" ACTIVEMQ_AMQP_PORT="5672" ACTIVEMQ_STOMP_PORT="61613" \
    ACTIVEMQ_MQTT_PORT="1883" ACTIVEMQ_WS_PORT="61614" PROTECTED_BROKER=false


CMD ["/entrypoint.sh"]