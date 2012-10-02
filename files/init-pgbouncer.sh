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

DAEMON=/usr/bin/pgbouncer
DNAME=pgbouncer
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
        if [ ! -d "${PGB_BASEDIR[$i]}" ]; then
            echo >&2 "pgbouncer $i: no base directory ${PGB_BASEDIR[$i]}"
            errors=$(($errors+1))
        fi
    done
    [ $errors -eq 0 ] || exit 1
}

check_config

start_pgbouncer() {
    NAME="$1"
    USER="$2"
    BASEDIR="$3"
    PREFIXCMD="$4"
    OPTIONS="$5"

    #START="--start --quiet --exec ${DAEMON} --name ${NAME} --pidfile ${BASEDIR}/twistd.pid"
    #[ -n "${USER}" ] && START="${START} --chuid ${USER}"
    #START="${START} -- start ${BASEDIR} ${OPTIONS}"
    #${PREFIXCMD} start-stop-daemon ${START} >/dev/null 2>&1
    ${PREFIXCMD} su -s /bin/sh -c "${DAEMON} start ${BASEDIR} ${OPTIONS}" - ${USER}
    return $?
}

stop_pgbouncer() {
    NAME="$1"
    USER="$2"
    BASEDIR="$3"
    PREFIXCMD="$4"

    ${PREFIXCMD} su -s /bin/sh -c "${DAEMON} stop ${BASEDIR}" - ${USER}
    return $?
}

reload_pgbouncer() {
    NAME="$1"
    USER="$2"
    BASEDIR="$3"
    PREFIXCMD="$4"

    if test -f ${BASEDIR}/master.cfg; then
        ${PREFIXCMD} su -s /bin/sh -c "${DAEMON} sighup ${BASEDIR}" - ${USER}
    else
        echo -n " not sighup-ing slave"
    fi
    return $?
}

do_start () {
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        log_daemon_msg "Starting pgbouncer ${PGB_NAME[$i]}"
        if start_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_BASEDIR[$i]}" \
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

do_stop () {
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        log_daemon_msg "Stopping pgbouncer ${PGB_NAME[$i]}"
        if stop_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_BASEDIR[$i]}" \
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
        log_daemon_msg "Reload pgbouncer ${PGB_NAME[$i]}"
        if reload_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_BASEDIR[$i]}" \
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

do_restart () {
    errors=0
    for i in ${PGB_NUMBER[@]}; do
        [ $i -ge 0 ] || continue
        log_daemon_msg "Restarting pgbouncer ${PGB_NAME[$i]}"
        stop_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_BASEDIR[$i]}" \
            "${PGB_PREFIXCMD[$i]}" || true
        if start_pgbouncer "${PGB_NAME[$i]}" "${PGB_USER[$i]}" "${PGB_BASEDIR[$i]}" \
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
