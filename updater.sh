#!/bin/bash

trap 'echo "INTERRUPTED" | tee -a $logfile; notify-send -t 100 "Update" "Command Interrupted"; exit 1' SIGINT
##PREPARING
path=`dirname $0`
logfile="$path/updater.log"
if [ ! -f $logfile ]; then 
 touch $logfile
 echo "++++logfile CREATED++++"
fi

##LOGGING
echo "**********************************************$(date) UPDATE****************************************************" >> "$logfile"
echo "starting $(date)" | tee -a "$logfile"
notify-send -t 100 "Update" "starting.."

##UPDATING
sudo pacman -Syu --noconfirm --color=always 2>&1 | tee -a "$logfile"

notify-send -t 100 "Update" "AUR"
echo "Searching AUR.."
echo "---AUR---" >> "$logfile"

yay -Syu --noconfirm --color=always 2>&1 | tee -a "$logfile"

##NOTIFYING
notify-send "Update" "Command Completed"
echo "COMPLETED" 
