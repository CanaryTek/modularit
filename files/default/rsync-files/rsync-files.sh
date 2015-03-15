#!/bin/bash
#
# Synchronize files using rsync
#

# Config dir
CONFDIR=/etc/rsync-files

MASTER="fw1.galacocanarias.com"
if [ -z "$SLAVE" ]
then
    SLAVE="fw2"
fi

# If not in master warn and exit
if [ `uname -n` != "$MASTER" ]; then
	echo "ERROR!!! this script should be run from $MASTER"
	exit 1
fi

for server in $SLAVE; do
  echo "*** Synchronizing to $server ***"
  for module in `ls /etc/rsync-files/modules`; do
    dir=$CONFDIR/modules/$module
    echo "  ** Procesing module $module **"
    if [ ! -f $dir/files ]; then
	    echo "WARNING: Skipping module $module because of missing 'files' files"
	    continue
    fi 
    for entry in `cat $dir/files`; do
      source=`echo $entry | cut -d: -f1`
      target=`echo $entry | cut -d: -f2`
      # Compose additional args
      rsync_cmd="rsync -avz $source --delete $server:$target"
      if [ -f $dir/files.include ]; then
        rsync_cmd="$rsync_cmd --include-from $dir/files.include"
      fi
      if [ -f $dir/files.exclude ]; then
        rsync_cmd="$rsync_cmd --exclude-from $dir/files.exclude"
      fi
      echo $rsync_cmd
      $rsync_cmd
    done
  done

done

