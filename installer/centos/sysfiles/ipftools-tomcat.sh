#! /bin/sh
#
# Tomcat 6 server for IPF Tools
#
# chkconfig: - 90 10
# description: Tomcat 6 server for IPF Tools
#

# Source function library.
. /etc/init.d/functions

if [ -f /etc/sysconfig/ipftools-tomcat ]; then
    . /etc/sysconfig/ipftools-tomcat
fi

RUN_AS_USER=apache
CATALINA_HOME=/opt/ipftools/tomcat
: ${JAVA_HOME:=/opt/ipftools/jre}
export CATALINA_HOME JAVA_HOME

start() {
    local mesg="Starting IPF Tools Tomcat:"
    if [ "x$USER" != "x$RUN_AS_USER" ]; then
        action "$mesg" su -s /bin/sh $RUN_AS_USER -c \
            "JAVA_HOME=$JAVA_HOME CATALINA_HOME=$CATALINA_HOME $CATALINA_HOME/bin/startup.sh >/dev/null 2>&1"
        RETVAL=$?
    else
        action "$mesg" env JAVA_HOME=$JAVA_HOME CATALINA_HOME=$CATALINA_HOME $CATALINA_HOME/bin/startup.sh >/dev/null 2>&1
        RETVAL=$?
    fi
    return $RETVAL
}

stop() {
    local mesg="Shutting down IPF Tools Tomcat:"
    if [ "x$USER" != "x$RUN_AS_USER" ]; then
        action "$mesg" su -s /bin/sh - $RUN_AS_USER -c \
            "JAVA_HOME=$JAVA_HOME CATALINA_HOME=$CATALINA_HOME $CATALINA_HOME/bin/shutdown.sh >/dev/null 2>&1"
        RETVAL=$?
    else
        action "$mesg" env JAVA_HOME=$JAVA_HOME CATALINA_HOME=$CATALINA_HOME $CATALINA_HOME/bin/shutdown.sh >/dev/null 2>&1
        RETVAL=$?
    fi
    return $RETVAL
}

case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    stop
    for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
        sleep 1
        pid="`cat $CATALINA_HOME/work/catalina.pid 2>/dev/null || :`"
        [ -z "$pid" ] && break
        kill -0 $pid || break
    done
    start
    ;;
*)
    echo "Usage: $0 {start|stop|restart}"
esac

exit 0
