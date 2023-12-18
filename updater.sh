#!/bin/bash
trap 'echo "INTERRUPTED" | tee -a $log_file; notify-send -t 100 "Update" "Interrupted"; exit 1' SIGINT

#Find the directory of script
path=`dirname $0`

#path of yay and pacman
pacman=`which pacman`
yay=`which yay`

#Construct path of logfile and configfile
config_file="$path/updater.cfg"
log_file="$path/updater.log"
readme_file="$path/README.md"

#Create logfile and configfile if not found
if [ ! -f $log_file ]; then 
 touch $log_file
 echo "++++logfile CREATED++++" | tee -a "$log_file"
fi
if [ ! -f $config_file ]; then
 touch $config_file
 echo "++++Configfile created++++" | tee -a "$log_file"
 echo "#Set to true to check for AUR updates" >> "$config_file"
 echo "perform_AUR_Update=true" >> "$config_file"
 echo " " >> "$config_file"
 echo "#Set to true to update ClamAV database (recommended)" >> "$config_file"
 echo "perform_ClamAVdb_update=true" >> "$config_file"
 echo "CONFIG FILE POPULATED" | tee -a "$log_file"
fi
source $config_file

#Setting file permissions
chmod 700 $path
chmod 544 $0
chmod 644 $log_file
chmod 644 $config_file
chmod 444 $readme_file

##LOGGING
echo "**********************************************$(date) UPDATE****************************************************" >> "$log_file"
echo "Starting $(date)" | tee -a "$log_file"
notify-send -h int:transient:1 -t 100 "Update" "starting.."

##UPDATING

#System update(PACMAN)
echo "System Update Starting..." | tee -a "$log_file"
sudo $pacman -Syu --noconfirm --color=always 2>&1 | tee -a "$log_file"
if [ $? -ne 0 ]; then
echo "Some errors occured during system update(using Pacman)" | tee -a "$log_file"
fi
#AUR update(YAY)
if [ "$perform_AUR_Update" = true ]; then
notify-send -h int:transient:1 -t 100 "Update" "AUR"
echo "----Searching AUR----"
echo "---AUR---" >> "$log_file"
$yay -Syu --noconfirm --color=always 2>&1 | tee -a "$log_file"
if [ $? -ne 0 ]; then
echo "Some errors occured during AUR update(using yay AUR helper)" | tee -a "$log_file"
fi
fi

#ClamAV database update (IF clamav is installed)
if [[ "$perform_ClamAVdb_update" = true && $(pacman -Qs clamav) > /dev/null ]]; then
 notify-send -h int:transient:1 -t 100 "Update" "ClamAV database"
 echo "ClamAV database.."
 echo "++++ClamAV database++++" >> "$log_file"
 sudo freshclam | tee -a "$log_file"
if [ $? -ne 0 ]; then
echo "Some errors occured during ClamAV database update(using freshclam command)" | tee -a "$log_file"
fi
fi

##NOTIFYING after completion
notify-send -h int:transient:1 "Update" "Command Completed"
echo "COMPLETED" 
exit 0
