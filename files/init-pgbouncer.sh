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

. /lib/lsb/init-functions

if [ ! -x ${DAEMON} ]
then
    log_failure_msg "Missing file: ${DAEMON}"
    exit 16
fi

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
    NAME="$1"
    PIDFILE=/var/run/postgresql/pgbouncer-${NAME}.pid
    pidofproc -p $PIDFILE $DAEMON >/dev/null
}

do_each () {
    local cmd="$1"
    local name="$2"
    local errors=0
    local number_of_instance=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        if [ \( -n "$name" -a ${PGB_NAME[$i]} = "$name" \) \
            -o -z "$name" ]; then
            case $cmd in
                start)
                    do_start $i $name
                    errors=$(($errors+$?));;
                stop)
                    do_stop $i $name
                    errors=$(($errors+$?));;
                reload)
                    do_reload $i $name
                    errors=$(($errors+$?));;
                status)
                    do_status $i $name
                    errors=$(($errors+$?));;
                *)
                    echo "Unknown command $cmd" >&2
                    errors=$(($errors+1));;
            esac
        fi
        number_of_instance=$i
    done
    status=$(($errors/($number_of_instance + 1)))
    log_daemon_msg "pgbouncer $cmd" "all"
    log_end_msg $status
    exit $?
}

start_pgbouncer() {
    NAME="$1"
    USER="$2"
    CONFILE="$3"
    PREFIXCMD="$4"
    OPTIONS="$5"
    PIDFILE=/var/run/postgresql/pgbouncer-${NAME}.pid

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
        is_running $NAME || return 0

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

    is_running $NAME || return 0

    killproc -p $PIDFILE $DAEMON HUP
    return $?
}

do_start () {
    local errors=0
    local i="$1"
    if is_running ${PGB_NAME[$i]}; then
        log_daemon_msg "Already started" "${PGB_NAME[$i]}"
        log_end_msg 0
    else
        log_daemon_msg "Starting pgbouncer" "${PGB_NAME[$i]}
"
        if start_pgbouncer \
            "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
            "${PGB_PREFIXCMD[$i]}" "${PGB_OPTIONS[$i]}"
        then
            log_daemon_msg "OK" "${PGB_NAME[$i]}"
            log_end_msg 0
        else
            log_failure_msg "KO" "${PGB_NAME[$i]}"
            errors=7
        fi
    fi
    return $errors
}

do_stop () {
    local errors=0
    local i="$1"
    if ! is_running ${PGB_NAME[$i]}; then
        log_daemon_msg "Already stopped" "${PGB_NAME[$i]}"
        log_end_msg 0
    else
        log_daemon_msg "Stopping pgbouncer" "${PGB_NAME[$i]}"
        if stop_pgbouncer \
            "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
            "${PGB_PREFIXCMD[$i]}"
        then
            log_end_msg 0
        else
            log_end_msg 1
            errors=6
        fi
    fi
    return $errors
}

do_reload () {
    local errors=0
    local i="$1"
    log_daemon_msg "Reload pgbouncer" "${PGB_NAME[$i]}"
    if reload_pgbouncer \
        "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
        "${PGB_PREFIXCMD[$i]}"
    then
        log_end_msg 0
    else
        log_end_msg 1
        errors=5
    fi
    return $errors
}

do_restart () {
    local errors=0
    local i="$1"
    log_daemon_msg "Restarting pgbouncer" "${PGB_NAME[$i]}"
    stop_pgbouncer \
        "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
        "${PGB_PREFIXCMD[$i]}" || true
    if start_pgbouncer \
        "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_CONFILE[$i]}" \
        "${PGB_PREFIXCMD[$i]}" "${PGB_OPTIONS[$i]}"
    then
        log_end_msg 0
    else
        log_end_msg 1
        errors=4
    fi
    return $errors
}

do_status() {
    local i="$1"
    local errors=0
    log_daemon_msg "Checking pgbouncer" "${PGB_NAME[$i]}"
    is_running ${PGB_NAME[$i]}
    rc=$?
    if [ $rc -eq 0 ]
    then
        log_success_msg " ... running"
    else
        log_warning_msg " ... not running!"
        errors=3
    fi
    return $errors
}

case "$1" in
  start)
        do_each start "$2"
        ;;
  stop)
        do_each stop "$2"
        ;;
  reload|force-reload)
        do_each reload "$2"
        ;;
  restart)
        do_each stop "$2"
        ;;
  try-restart)
        if $0 status >/dev/null; then
                $0 restart
        else
                exit 0
        fi
        ;;
  status)
        do_each status "$2"
        ;;
  *)
        log_warning_msg "Usage: $0 {start|stop|restart|reload|force-reload}"
        exit 1
        ;;
esac

exit 0
