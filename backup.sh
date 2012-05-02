#!/bin/sh
#
# This is my very easy backup skript. It is only invoked when the external 
# harddrive is mounted, so all the mounting/unmounting is not part of the
# system. Removing old snapshots is done manually so far. This would be nice to
# automaticaly do so, but will make the script much more complicated.
#
# Simply define the directory you want to backup and where all the backups
# should live. There can be a rsync exclude file at ~/.config/backup_excludes
# and you need to have a ~/.cache directory (which you should have anyway).
# you can only have one snapshot a minute (which should be no problem).

DATA=/home/johannes     # Files to backup
BACKUP_DIR=/mnt/backup  # Where to save the backups

# use XDG enviroment variables, if possible
if [ -z "$XDG_DATA_HOME" ]
then
  DATAHOME=$HOME/.local/share
else
  DATAHOME=$XDG_DATA_HOME
fi

if [ -z "$XDG_CONFIG_HOME" ]
then
  EXC_CONFIG="$XDG_CONFIG_HOME/backup_excludes"
else
  EXC_CONFIG="$HOME/.config/backup_excludes"
fi

# if there is an old backup, we want to hardlink all unchanged files
if [ -e $DATAHOME/old_backup ]
then
  echo 'Use hardlinks'
  OLD=`cat $DATAHOME/old_backup`
  HARDLINK="--link-dest=$BACKUP_DIR/$OLD"
fi

# if there is an rsync exclude file, use it
if [ -e $EXC_CONFIG ]
then
  echo 'Found excludes file'
  EXCLUDE="--delete-excluded --exclude-from=$EXC_CONFIG"
fi

# create new snapshot directory and rsync it
mkdir $BACKUP_DIR/new_snapshot
rsync -a --delete $EXCLUDE $HARDLINK $DATA/ $BACKUP_DIR/new_snapshot

# name the new snapshot
NAME=`date +%Y%m%d%H%M`
mv $BACKUP_DIR/new_snapshot $BACKUP_DIR/$NAME

# remember the last snapshot
echo $NAME > $DATAHOME/old_backup

