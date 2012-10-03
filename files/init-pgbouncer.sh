#! /bin/bash
# initscript for pgbouncer

### BEGIN INIT INFO
# Provides:          pgbouncer
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DESC="Pgbouncer"

USER=pgbouncer

DNAME=pgbouncer
DAEMON=/usr/sbin/$DNAME
PROCNAME=$NAME

[ -r /etc/default/pgbouncer ] && . /etc/default/pgbouncer

test -x ${DAEMON} || exit 0

. /lib/lsb/init-functions

check_config()
{
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        if [ -z "${PGB_NAME[$i]}" ]; then
            echo >&2 "pgbouncer $i: no name"
            errors=$(($errors+1))
        fi
        if [ -z "${PGB_USER[$i]}" ]; then
            echo >&2 "pgbouncer $i: no user"
            errors=$(($errors+1))
        elif ! getent passwd ${PGB_USER[$i]} >/dev/null; then
            echo >&2 "pgbouncer $i: unknown user ${PGB_USER[$i]}"
            errors=$(($errors+1))
        fi
        if [ ! -e "${PGB_CONFILE[$i]}" ]; then
            echo >&2 "pgbouncer $i: no configuration file ${PGB_CONFILE[$i]}"
            errors=$(($errors+1))
        fi
    done
    [ $errors -eq 0 ] || exit 1
}

check_config

is_running() {
    PIDFILE="$1"
    pidofproc -p $PIDFILE $DAEMON >/dev/null
}

start_pgbouncer() {
    NAME="$1"
    USER="$2"
    CONFILE="$3"
    PREFIXCMD="$4"
    OPTIONS="$5"
    PIDFILE=/var/run/postgresql/pgbouncer-${NAME}.pid

    #START="--start --quiet --exec ${DAEMON} --name ${NAME} --pidfile ${CONFILE}/twistd.pid"
    #[ -n "${USER}" ] && START="${START} --chuid ${USER}"
    #START="${START} -- start ${CONFILE} ${OPTIONS}"
    #${PREFIXCMD} start-stop-daemon ${START} >/dev/null 2>&1
    ${PREFIXCMD} su -s /bin/sh -c "${DAEMON} -d ${CONFILE}" - ${USER}
    return $?
}

stop_pgbouncer() {
    NAME="$1"
    USER="$2"
    CONFILE="$3"
    PREFIXCMD="$4"
    PIDFILE=/var/run/postgresql/pgbouncer-${NAME}.pid

    SIGS='INT TERM KILL'

    for sig in $SIGS
    do
        is_running $PIDFILE || return 0

        killproc -p $PIDFILE $DAEMON $sig
        sleep 1
    done

    return 2
}

reload_pgbouncer() {
    NAME="$1"
    USER="$2"
    CONFILE="$3"
    PREFIXCMD="$4"
    PORT="$5"
    PIDFILE=/var/run/postgresql/pgbouncer-${NAME}.pid

    is_running $PIDFILE || return 0

    killproc -p $PIDFILE $DAEMON HUP
    return $?
}

do_start () {
    local instance="$1"
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        if [ \( -n "$instance" -a ${PGB_NAME[$i]} = "$instance" \) \
            -o -z "$instance" ]; then
            log_daemon_msg "Starting pgbouncer ${PGB_NAME[$i]}"
            if start_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
                "${PGB_PREFIXCMD[$i]}" "${PGB_OPTIONS[$i]}"
            then
                log_end_msg 0
            else
                log_end_msg 1
                errors=$(($errors+1))
            fi
        fi
    done
    return $errors
}

do_stop () {
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        log_daemon_msg "Stopping pgbouncer ${PGB_NAME[$i]}"
        if stop_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
            "${PGB_PREFIXCMD[$i]}"
        then
            log_end_msg 0
        else
            log_end_msg 1
            errors=$(($errors+1))
        fi
    done
    return $errors
}

do_reload () {
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        if [ \( -n "$instance" -a ${PGB_NAME[$i]} = "$instance" \) \
            -o -z "$instance" ]; then
        log_daemon_msg "Reload pgbouncer ${PGB_NAME[$i]}"
        if reload_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
            "${PGB_PREFIXCMD[$i]}"
        then
            log_end_msg 0
        else
            log_end_msg 1
            errors=$(($errors+1))
        fi
        fi
    done
    return $errors
}

do_restart () {
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        log_daemon_msg "Restarting pgbouncer ${PGB_NAME[$i]}"
        stop_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
            "${PGB_PREFIXCMD[$i]}" || true
        if start_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
            "${PGB_PREFIXCMD[$i]}" "${PGB_OPTIONS[$i]}"
        then
            log_end_msg 0
        else
            log_end_msg 1
            errors=$(($errors+1))
        fi
    done
    return $errors
}

case "$1" in
  start)
        do_start
        exit $?
        ;;
  stop)
        do_stop
        exit $?
        ;;
  reload)
        do_reload
        exit $?
        ;;
  restart|force-reload)
        do_restart
        exit $?
        ;;
  *)
        log_warning_msg "Usage: $0 {start|stop|restart|reload|force-reload}"
        exit 1
        ;;
esac

exit 0
