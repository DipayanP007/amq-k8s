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
  sed -i "s#<plugins><simpleAuthenticationPlugin><users><authenticationUser username="system" password="manager" groups="users,admins"/></users></simpleAuthenticationPlugin></plugins>##" conf/activemq.xml 
elif [[ $PROTECTED_BROKER == true ]]; then
echo "using protected boker"
  if [ ! -z "$ACTIVEMQ_USERNAME" ]; then
    echo "Setting activemq username to $ACTIVEMQ_USERNAME"
    broker_user=$ACTIVEMQ_USERNAME
    sed -i "s#activemq.username=system#activemq.username=$ACTIVEMQ_USERNAME#" conf/credentials.properties
  fi
 
if [ ! -z "$ACTIVEMQ_PASSWORD" ]; then
  echo "Setting activemq password"
  broker_pass=$ACTIVEMQ_PASSWORD
  sed -i "s#activemq.password=manager#activemq.password=$ACTIVEMQ_PASSWORD#" conf/credentials.properties
fi
echo "setting user and pwd for amq"
sed -i "s#<plugins><simpleAuthenticationPlugin><users><authenticationUser username="system" password="manager" groups="users,admins"/></users></simpleAuthenticationPlugin></plugins>#<plugins><simpleAuthenticationPlugin><users><authenticationUser username="${broker_user}" password="${broker_pass}" groups="users,admins"/></users></simpleAuthenticationPlugin></plugins>#" conf/activemq.xml 
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


mkdir -p $ACTIVEMQ_DATA_DIR
export ACTIVEMQ_OPTS="$ACTIVEMQ_OPTS -Dbroker.name=$ACTIVEMQ_BROKER_NAME -Ddata.dir=$ACTIVEMQ_DATA_DIR -Dheap.percent=$ACTIVEMQ_HEAP_PERCENT -Ddata.dir.size=$ACTIVEMQ_DATA_DIR_SIZE -Ddata.tmp.size=$ACTIVEMQ_DATA_TMP_SIZE -Dport.openwire=$ACTIVEMQ_OPENWIRE_PORT -Dport.amqp=$ACTIVEMQ_AMQP_PORT -Dport.stomp=$ACTIVEMQ_STOMP_PORT -Dport.mqtt=$ACTIVEMQ_MQTT_PORT -Dport.ws=$ACTIVEMQ_WS_PORT"

# Start
activemq console