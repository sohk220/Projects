#!/bin/bash
#
PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
if [ "$0" == "./$PROGNAME" ]; then
     PROGPATH="$(pwd)/${PROGPATH//./}"
fi

. $PROGPATH/utils.sh

WARN=0
CRIT=0
USER=''
NODE='In the CNN ID Pool'
URL=''
PASSWORD=''
HOST=''
HOSTNAME=''
PORT=''
MAXCONNS=0

usage() {
     echo ""
     echo "Script to monitor the CNN ID pool count on ardendo servers"
     echo "mod by pmk from plugin - check_mira"
     echo ""
     echo "Usage:"
     echo "$0 -H <HOSTNAME> -w <WARNING LEVEL> -c <CRITICAL LEVEL> "
     exit $STATE_UNKNOWN
}

if [ ! /var/log/nagios/cnn_id.log ]; then
     `touch /var/log/nagios/cnn_id.log`
fi

while getopts ":H:w:c:h:" opt; do
     case $opt in
          H )     HOST="$OPTARG" ;;
          w )      WARN=$OPTARG ;;
          c )      CRIT=$OPTARG ;;
          \?|h )     usage
               exit $STATE_UNKNOWN
     esac
done

if [ ! `which ssh 2> /dev/null` ]; then
     echo "UNKNOWN: ssh not found."
     exit $STATE_UNKNOWN
fi

if [ ! `which gawk 2> /dev/null` ]; then
     echo "UNKNOWN: gawk not found."
     exit $STATE_UNKNOWN
fi

if [ "$WARN" -eq 0 -o $CRIT -eq 0 ]; then
     echo "Parameter mismatch. Warning and crtical thresholds must not be 0."
     echo
     usage
elif [ "$WARN" -le $CRIT ]; then
     echo "Critical threshold must not be smaller than warning threshold."
     echo
     usage
fi


HOST_NAME=`host "${HOST}" | gawk '{print $5}'`
VALUE=`ssh nagios@$HOST /home/nagios/check_id_count`;
#VALUE=`ssh $HOST /opt/best/getcnnidcount.sh`;
VALUE=`echo $VALUE | grep -Eo [[:digit:]]\{1,3\}`



VALUE=${VALUE/<$NODE>/};
VALUE=${VALUE/<\/$NODE>/};


if [ "$VALUE" -le "$CRIT" 2> /dev/null ]; then
     echo "`date` CRITICAL: ${VALUE} ${NODE} ${HOST_NAME}" >> /var/log/nagios/cnn_id.log
     echo "CRITICAL: $VALUE $NODE - ${HOST_NAME}"
     exit $STATE_CRITICAL
elif [ "$VALUE" -le "$WARN" ] && [ "$VALUE" -gt "$CRIT" 2> /dev/null ]; then
     echo "`date` WARNING: ${VALUE} ${NODE} ${HOST_NAME}" >> /var/log/nagios/cnn_id.log
     echo "WARNING: $VALUE $NODE - ${HOST_NAME}"
     exit $STATE_WARNING
elif [ ${VALUE} -ge ${WARN} 2> /dev/null ]; then
     echo "`date` OK: ${VALUE} ${NODE} ${HOST_NAME}" >> /var/log/nagios/cnn_id.log
     echo "OK: $VALUE $NODE - ${HOST_NAME}"
     exit $STATE_OK
else
     echo "UNKNOWN: $VALUE | No recognizable value returned to plugin from $HOST_NAME"
     exit $STATE_UNKNOWN
fi
