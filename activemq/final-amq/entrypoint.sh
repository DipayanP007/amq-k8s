#!/bin/bash

activemq_webadmin_username="admin"
activemq_webadmin_pw="admin"
broker_user="system"
broker_pass="manager"
## Modify jetty.xml

# WebConsole to listen on all addresses (beginning with 5.16.0, it listens on 127.0.0.1 by default, so is unreachable in Container)
# Bind to all addresses by default. Can be disabled setting ACTIVEMQ_WEBCONSOLE_USE_DEFAULT_ADDRESS=true
echo "Allowing WebConsole listen to 0.0.0.0"
sed -i 's#<property name="host" value="127.0.0.1"/>#<property name="host" value="0.0.0.0"/>#' conf/jetty.xml


if [ ! -z "$ACTIVEMQ_ADMIN_CONTEXTPATH" ]; then
  echo "Setting activemq admin contextPath to $ACTIVEMQ_ADMIN_CONTEXTPATH"
  sed -iv "s#<property name=\"contextPath\" value=\"/admin\" />#<property name=\"contextPath\" value=\"${ACTIVEMQ_ADMIN_CONTEXTPATH}\" />#" conf/jetty.xml
  # The pattern to be replaced is the string 
  # <property name="contextPath" value="/admin" /> and the replacement string is, 
  # <property name="contextPath" value="${ACTIVEMQ_ADMIN_CONTEXTPATH}" />
fi

if [ ! -z "$ACTIVEMQ_API_CONTEXTPATH" ]; then
  echo "Setting activemq API contextPath to $ACTIVEMQ_API_CONTEXTPATH"
  sed -iv "s#<property name=\"contextPath\" value=\"/api\" />#<property name=\"contextPath\" value=\"${ACTIVEMQ_API_CONTEXTPATH}\" />#" conf/jetty.xml
fi

if [[ $PROTECTED_BROKER == "false" ]]; then
echo "not using protected broker"
  sed -i "s#<plugins><simpleAuthenticationPlugin><users><authenticationUser username=\"\${activemq.username}\" password=\"\${activemq.password}\" groups=\"users,admins\"/></users></simpleAuthenticationPlugin></plugins>##" conf/activemq.xml 
fi

if [ ! -z "$ACTIVEMQ_WEBADMIN_USERNAME" ]; then
  activemq_webadmin_username=$ACTIVEMQ_WEBADMIN_USERNAME
  has_modified_webadmin_username="username"
fi

if [ ! -z "$ACTIVEMQ_WEBADMIN_PASSWORD" ]; then
  activemq_webadmin_pw="$ACTIVEMQ_WEBADMIN_PASSWORD"
  has_modified_webadmin_pw=" and password"
fi

if [ ! -z "$ACTIVEMQ_WEBADMIN_USERNAME"  ] || [ ! -z "$ACTIVEMQ_WEBADMIN_PASSWORD" ]; then
  echo "Setting activemq WebConsole $has_modified_webadmin_username $has_modified_webadmin_pw"
  sed -i "s#admin: admin, admin#$activemq_webadmin_username: $activemq_webadmin_pw, admin#" conf/jetty-realm.properties
fi

if [[ "$ACTIVEMQ_SQL_DATASTORE" == true ]]; then
  echo "Setting activemq SQL Server datastore"
  sed -i "s#<kahaDB directory=\"\${data.dir}/kahadb\"/>#<jdbcPersistenceAdapter dataDirectory=\"\${data.dir}/data\" dataSource=\"\#mssql-ds\" lockKeepAlivePeriod=\"3000\" adapter=\"\#jdbcAdapter\" locker=\"\#databaseLocker\"><locker><lease-database-locker lockAcquireSleepInterval=\"6000\"/></locker></jdbcPersistenceAdapter>#g" conf/activemq.xml
  echo "Setting SQL Server connection properties"
  if [ ! -z "$ACTIVEMQ_SQL_JDBC_CONNECTION_STRING" ]; then
  sed -i "s#<property name=\"url\" value=\"jdbc:sqlserver://localhost:1433;databaseName=admin;encrypt=true;trustServerCertificate=true;\"/>#<property name=\"url\" value=\"${ACTIVEMQ_SQL_JDBC_CONNECTION_STRING}\"/>#g" conf/sql.xml
  else 
  sql_hostname=$ACTIVEMQ_SQL_HOSTNAME
  sql_database=${ACTIVEMQ_SQL_DATABASE:-activemq}
  sql_port=${ACTIVEMQ_SQL_PORT:-1433}
  sed -i "s#<property name=\"url\" value=\"jdbc:sqlserver://localhost:1433;databaseName=admin;encrypt=true;trustServerCertificate=true;\"/>#<property name=\"url\" value=\"jdbc:sqlserver://${sql_hostname}:${sql_port};databaseName=${sql_database};encrypt=true;trustServerCertificate=true;\"/>##g" conf/sql.xml
  fi
  sql_username=${ACTIVEMQ_SQL_USERNAME:-admin}
  sql_password=${ACTIVEMQ_SQL_PASSWORD:-admin}
  sed -i "s#<property name=\"username\" value=\"admin\"/>#<property name=\"username\" value=\"${sql_username}\"/>#g" conf/sql.xml
  sed -i "s#<property name=\"password\" value=\"admin\"/>#<property name=\"password\" value=\"${sql_password}\"/>#g" conf/sql.xml

else
sed -i "s#<import resource=\"sql.xml\"/>##g" conf/activemq.xml
fi

mkdir -p $ACTIVEMQ_DATA_DIR/kahadb
#export ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS -Dbroker.name=$ACTIVEMQ_BROKER_NAME -Ddata.dir=$ACTIVEMQ_DATA_DIR -Ddata.dir.size=$ACTIVEMQ_DATA_DIR_SIZE -Ddata.tmp.size=$ACTIVEMQ_DATA_TMP_SIZE -Dport.openwire=$ACTIVEMQ_OPENWIRE_PORT -Dport.amqp=$ACTIVEMQ_AMQP_PORT -Dport.stomp=$ACTIVEMQ_STOMP_PORT -Dport.mqtt=$ACTIVEMQ_MQTT_PORT -Dport.ws=$ACTIVEMQ_WS_PORT"

echo "*************** Starting Activemq ***************"

# Start
exec activemq console
