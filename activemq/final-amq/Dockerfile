FROM eclipse-temurin:8-jre-jammy

ENV ACTIVEMQ_VERSION 5.10.0
ENV ACTIVEMQ apache-activemq-$ACTIVEMQ_VERSION
ENV ACTIVEMQ_HOME="/opt/activemq" PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/activemq/bin:/opt/java/openjdk/bin"

COPY entrypoint.sh conf/activemq.xml /
WORKDIR /tmp

ADD https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz .

RUN mkdir -p /opt/activemq && \
    tar -xvf apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz && \
    mv $ACTIVEMQ/* ${ACTIVEMQ_HOME} &&\
    groupadd activemq && \
    useradd -s /bin/bash -g activemq -d $ACTIVEMQ_HOME activemq && \
    rm $ACTIVEMQ_HOME/conf/activemq.xml && \
    mv /activemq.xml ${ACTIVEMQ_HOME}/conf && \
    chown -R activemq:activemq $ACTIVEMQ_HOME && \
    chmod 777 /entrypoint.sh 
WORKDIR ${ACTIVEMQ_HOME}

EXPOSE 61616 8161

USER activemq

ENV ACTIVEMQ_BROKER_NAME="activemq-on-docker" ACTIVEMQ_DATA_DIR="/opt/activemq/data" ACTIVEMQ_DATA_DIR_SIZE="100" ACTIVEMQ_DATA_TMP_SIZE="50" ACTIVEMQ_OPENWIRE_PORT="61616" ACTIVEMQ_AMQP_PORT="5672" ACTIVEMQ_STOMP_PORT="61613" ACTIVEMQ_MQTT_PORT="1883" ACTIVEMQ_WS_PORT="61614"

CMD ["/entrypoint.sh"]

