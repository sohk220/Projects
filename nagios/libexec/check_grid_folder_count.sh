#! /bin/bash
##########################################################################################
#   check_grid_folder_count.sh
#   Script will check the folder count within the specefied directory path on the file system.
#   v.02 Paul Kayhart 01-29-2011
##########################################################################################


PROGNAME=`basename $0`
PROGPATH=`echo $0 | sed -e 's,[\\/][^\\/][^\\/]*$,,'`
if [ "$0" == "./$PROGNAME" ]; then
     PROGPATH="$(pwd)/${PROGPATH//./}"
fi

. $PROGPATH/utils.sh


# A few variables declared.

WARN=0
CRIT=0
GRID='A'
MAS='omnmas1app1'
IP1='10.164.216.134'
IP2='10.164.219.218 10.164.219.219'
NODE=''
FOLDER=''
 
# Syntax for the plugin arguments

usage() {
     echo ""
     echo ""
     echo "#######################################################################################################"
     echo ""
     echo "    Script to monitor the subdirectory count in /editor/Render Files/Render Files/ on a GRID"
     echo ""
     echo "    $0"
     echo ""
     echo "    Usage:"
        echo "    [ -w <WARNING LEVEL> -c <CRITICAL LEVEL> -g <GRID> -m <MAS App Server> -f <folder_name> ]"
     echo ""
     echo "    GRID must be  \"A\" or \"B\" - MAS app server must be in the form \"omnmas1app1-ny\""
     echo ""
     echo ""   folder_name should be \"Render Files/Render Files\" for this specific check
     echo ""
     echo "#######################################################################################################"
     echo ""
     exit $STATE_UNKNOWN
}


# Collecting some arguments. Missing arguments will result in usage display

while getopts ":w:c:g:m:f:" opt; do
     case $opt in
          w )      WARN=$OPTARG ;;
          c )      CRIT=$OPTARG ;;
          g )      GRID="$OPTARG" ;;
          m )     MAS="$OPTARG" ;;
                f )     FOLDER="$OPTARG" ;;
          \? )     usage

#  If all else fails within this case structure, lets just bail

               echo "bad karma  somewhere"
               exit $STATE_UNKNOWN
     esac
done



# IP1 represents the mount point of the grid on the MAS servers.

if      [ "$GRID" = "A" 2> /dev/null ]; then
          IP1="10.164.219.208"
elif      [ "$GRID" = "B" 2> /dev/null ]; then
          IP1="10.164.219.208"

else
          echo "COMMAND LINE SYNTAX ERROR: Invalid Grid specified"
          exit $STATE_UNKNOWN

fi

# Below, IP2 represents the address of the MAS server being polled to get the result.

if      [ "$MAS" = "nycnn-ms2app3" 2> /dev/null ]; then
          IP2="10.164.219.218"
elif      [ "$MAS" = "nycnn-ms2app4" 2> /dev/null ]; then
          IP2="10.164.219.219"

else
          echo "COMMAND LINE SYNTAX ERROR: Invalid MAS App Server specified"
          exit $STATE_UNKNOWN

fi


# Some more error handling

if [ ! `which wc 2>/dev/null` ]; then
     echo "UNKNOWN: wc program not found."
     exit $STATE_UNKNOWN
fi

if [ $WARN -eq 0 -o $CRIT -eq 0 ]; then
     echo "Parameter mismatch. Warning and crtical thresholds must not be 0."
     echo
     usage
elif [ $WARN -ge $CRIT ]; then
     echo "Critical threshold must not be smaller than warning threshold."
     echo
     usage
fi


# The following is the remote ssh command executive that retrieves the folder
# count in editor/projects/,  /editor/resources or in the Render Files directory.
# The 30K limit is specific to the number of sub-directories within any given directory. It is an inode limit in Linux EXT2 file systems
# It lists only visible directories. It will include symbolic links in the count and is not recursive.
# The commented line is actually better code but takes too long on such a large directory.


#VALUE=`ssh -l nagios $IP2 -C "cd /mnt/$IP1/omneon/Grid_A/editor/'$FOLDER'/; ls -d */ | wc -l"`;
VALUE=`ssh -l nagios $IP2 -C "cd /Volumes/GridA/editor/'$FOLDER'/; ls -d */ | wc -l"`;
VALUE=`ssh -l nagios $IP2 -C "ls -ld /Volumes/GridA/editor/Render\ Files/* |wc -l"`;


VALUE=${VALUE/<$NODE>/};
VALUE=${VALUE/<\/$NODE>/};

if [ $VALUE -ge $CRIT 2> /dev/null ]; then
     echo "Grid $GRIDF CRITICAL: $VALUE $NODE subdirectories in $FOLDER"
     exit $STATE_CRITICAL
elif [ $VALUE -ge $WARN 2> /dev/null ]; then
     echo "Grid $GRID WARNING: $VALUE $NODE subdirectories in $FOLDER"
     exit $STATE_WARNING
elif [ $VALUE -ge 0 2> /dev/null ]; then
     echo "Grid $GRID OK: $VALUE $NODE subdirectories in $FOLDER"
     exit $STATE_OK
else
     echo "Grid $GRID UNKNOWN: Cannot determine value"
     exit $STATE_UNKNOWN
fi
