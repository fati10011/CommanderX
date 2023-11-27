#!/usr/bin/env bash

function checkPassword(){
	password=$(zenity --forms --title="CommanderX - Login" --text="Enter your password for $USER:" --add-password="Password:")
	echo $password | sudo -S -v
	while ! [ $? -eq 0 ]; do
    		password=$(zenity --forms --title="CommanderX - Login" --text="Authentication failed, please enter your password for $USER:" --add-password="Password:")
		echo $password | sudo -S -v
	done
	mainMenu
}

function mainMenu(){
	selection=$(zenity --list --title="CommanderX" --text="Choose an option:" --column="Options" "SOFTWARE MANAGEMENT" "PROCESS MANAGEMENT" "TASK SCHEDULING" "STORAGE DEVICE MANAGEMENT" "EXIT" --width=1000 --height=700)

	case $selection in
	  "SOFTWARE MANAGEMENT")
	    softwareManagementMenu
	    ;;
	  "PROCESS MANAGEMENT")
	    processManagementMenu
	    ;;
	  "TASK SCHEDULING")
	    taskSchedulingMenu
	    ;;
	  "STORAGE DEVICE MANAGEMENT")
	    storageDeviceManagementMenu
	    ;;
	   "EXIT")
		 	echo
		 	echo "<3"
	    exit 0
	    ;;
	esac
}

# SOFTWARE MANAGEMENT #

function softwareManagementMenu(){
	selection=$(zenity --list --title="SOFTWARE MANAGEMENT" --text="Please choose an option:" --column="Options" "Update package list" "Install pending updates" "Search for a package" "Install a package" "BACK" --width=1000 --height=700)

	case $selection in
	  "Update package list")
			sudo apt-get update | tee >(zenity --progress --pulsate --text="Updating packages, please wait..." --auto-close )
			zenity --info --text="Update complete"
	    softwareManagementMenu
	    ;;
	  "Install pending updates")
			sudo apt-get upgrade -y | tee >(zenity --progress --pulsate --text="Installing pending updates, please wait..." --auto-close )
			zenity --info --text="Update complete"
	    softwareManagementMenu
	    ;;
	  "Search for a package")
	    packageToSearch=$(zenity --entry --title "Search package" --text "Enter the pattern to search for:" --width=1000 --height=700)
	    dpkg -S $packageToSearch | sed -e 's/:/:\n/g' | zenity --text-info --title "Packages found" --width=1000 --height=700 --no-wrap
	    softwareManagementMenu
	    ;;
	  "Install a package")
	    packageToInstall=$(zenity --entry --title "Install package" --text "Enter the name of the package you want to install:" --width=1000 --height=700)
	    sudo apt install $packageToInstall -y
	    softwareManagementMenu
	    ;;
	   "BACK")
	    mainMenu
	    ;;
	esac
}

# PROCESS MANAGEMENT #

function processManagementMenu(){
	selectionPM=$(zenity --list --title="PROCESS MANAGEMENT" --text="Please choose an option:" --column="Options" "Show processes" "Kill process" "BACK" --width=1000 --height=700)

  case $selectionPM in
    "Show processes")
			showProcessesMenu
		;;
    "Kill process")
			killProcessMenu
		;;
   "BACK")
    	mainMenu
   	;;
  esac
}

function showProcessesMenu(){
	selection=$(zenity --list --title="SHOW PROCESSES" --text="Please choose an option:" --column="Options" "Show all processes" "Show all processes ordered by CPU usage" "Show all processes ordered by RAM usage" "BACK" --width=1000 --height=700)
  case $selection in
    "Show all processes")
		  ps -aux | awk  '{printf "%-20s %-10s %-5s %-5s %-10s %-30s\n", $1, $2, $3, $4, $10, $11}' | zenity --text-info --title "Top Output" --no-wrap --width=1000 --height=700 --font="Courier"
		  processManagementMenu
		;;
    "Show all processes ordered by CPU usage")
		  ps -aux --sort=-%cpu | awk  '{printf "%-20s %-10s %-5s %-5s %-10s %-30s\n", $1, $2, $3, $4, $10, $11}' | zenity --text-info --title "Top Output" --no-wrap --width=1000 --height=700 --font="Courier"
		  processManagementMenu
		;;
    "Show all processes ordered by RAM usage")
		  ps -aux --sort=-%cpu | awk  '{printf "%-20s %-10s %-5s %-5s %-10s %-30s\n", $1, $2, $3, $4, $10, $11}' | zenity --text-info --title "Top Output" --no-wrap --width=1000 --height=700 --font="Courier"
		  processManagementMenu
		;;
    "BACK")
    	processManagementMenu
   	;;
  esac
}

function killProcessMenu(){
	selection=$(zenity --list --title="KILL PROCESSES" --text="Please choose an option:" --column="Options" "Kill process by name" "Kill process by PID" "BACK" --width=1000 --height=700)
	case $selection in
		"Kill process by name")
			processToKill=$(zenity --entry --title "Kill process" --text "Enter the name of the process you want to kill:" --width=1000 --height=700)
			pkill $processToKill
		  processManagementMenu
		;;
		"Kill process by PID")
			processToKill=$(zenity --entry --title "Kill process" --text "Enter the PID of the process you want to kill:" --width=1000 --height=700)
			kill $processToKill
		  processManagementMenu
		;;
    "BACK")
    	processManagementMenu
   	;;
	esac
}

# STORAGE DEVICE MANAGEMENT #

function storageDeviceManagementMenu(){
	selection=$(zenity --list --title="STORAGE DEVICE MANAGEMENT" --text="Please choose an option:" --column="Options" "Mount device" "Unmount device" "Show mounted disks" "BACK" --width=1000 --height=700)
	case $selection in
		"Mount device")
			body=$(sudo fdisk -l | grep '^/dev/' | awk '{print $1}' )
			diskToMount=$(zenity --list --column="Partitions" $body --text "Select the partition to mount:" --width=1000 --height=700)
			mountPoint=$(zenity --file-selection --directory --width=1000 --height=700)
			sudo mount $diskToMount $mountPoint
			storageDeviceManagementMenu
		;;
		"Unmount device")
			header=$(df -h | awk 'NR==1  {print $1}')
			body=$(df -h -x tmpfs -x devtmpfs | awk 'NR>1  {print $1}')
			diskToUnmount=$(zenity --list --column "$header" --text "Select the partition to unmount:" --print-column=1 <<< "$body" --width=1000 --height=700)
			sudo umount $diskToUnmount
			storageDeviceManagementMenu
		;;
		"Show mounted disks")
			header=$(df -h | awk 'NR==1  { printf "%-30s %-20s %-10s %-10s %20s\n", $1, $2, $3, $4, $5 }')
			body=$(df -h -x tmpfs -x devtmpfs | awk 'NR>1  { printf "%-30s %-20s %-10s %-10s %20s\n", $1, $2, $3, $4, $5 }')
			zenity --list --column "$header" --text "Select a partition:" --print-column=1 <<< "$body" --width=1000 --height=700  -font="Courier"
			storageDeviceManagementMenu
		;;
    "BACK")
    	mainMenu
   	;;
	esac
}

# TASK SCHEDULING #

function taskSchedulingMenu() {
  selection=$(zenity --list --title="TASK SCHEDULING" --text="Please choose an option:" --column="Options" "Root's crontab" "User's crontab" "BACK" --width=1000 --height=700)
  case $selection in
    "Root's crontab" )
        rootCrontabMenu
    ;;
    "User's crontab" )
       userCrontabMenu
    ;;
    "BACK" )
      mainMenu
    ;;
  esac
}

function rootCrontabMenu() {
  selectionRC=$(zenity --list --title="ROOT'S CRONTAB" --text="Please choose an option:" --column="Options" "View crontab" "Edit crontab" "Delete crontab" "BACK" --width=1000 --height=700)
  case $selectionRC in
    "View crontab" )
      zenity --text-info --filename="/etc/crontab"
			rootCrontabMenu
    ;;
    "Edit crontab" )
      newContent=$(zenity --text-info --editable --filename="/etc/crontab"  --width=1000 --height=700)
      echo "$newContent" | sudo tee /etc/crontab > /dev/null
			rootCrontabMenu
    ;;
    "Delete crontab" )
			if zenity --question --text="Are you sure you want to delete the crontab?" --title="Confirm deletion"; then
				sudo crontab -r -u root
			fi
			taskSchedulingMenu
		;;
    "BACK" )
      taskSchedulingMenu
    ;;
  esac
}

function userCrontabMenu() {
  username=$(authenticateUser)

  selectionUC=$(zenity --list --title="USER'S CRONTAB FOR $username" --text="Please choose an option:" --column="Options" "View crontab" "Edit crontab" "Delete crontab" "BACK" --width=1000 --height=700)
  case $selectionUC in
    "View crontab" )
      output=$(sudo crontab -u $username -l)
        if [ -z "$output" ]; then
        	echo "This user has no crontab" | zenity --text-info --editable --width=1000 --height=700 --no-wrap
        else
          echo "$output" | zenity --text-info --editable --width=1000 --height=700 --no-wrap
        fi
			userCrontabMenu
		;;
    "Edit crontab" )
      originalContent=$(sudo crontab -u $username -l)
      if [ -z "$originalContent" ]; then
        originalContent=$crontabDefault
      fi
      newContent=$(echo -en "$originalContent" | zenity --text-info --editable --width=1000 --height=700 --no-wrap)
      if [ "$newContent" != "$originalContent" ]; then
          echo "$newContent" | sudo crontab -u $username -
          zenity --info --title="Crontab updated" --text="Crontab updated for user $username"  --width=1000 --height=700
      fi
			userCrontabMenu
    ;;
    "Delete crontab" )
			if zenity --question --text="Are you sure you want to delete the crontab for user $username?" --title="Confirm deletion"; then
				sudo crontab -u $username -r
			fi
	    taskSchedulingMenu
		;;
    "BACK" )
      taskSchedulingMenu
    ;;
  esac
}

function authenticateUser() {
  result=$(zenity --forms --title="Login" --text="Enter your credentials:" --add-entry="Username:" --add-password="Password:"  --width=1000 --height=700)

  username=$(echo $result | awk -F'|' '{print $1}')
  password=$(echo $result | awk -F'|' '{print $2}')

  output=$(echo $password | su $username -c whoami)
  while [ "$output" != "$username" ]
  do
  	result=$(zenity --forms --title="Login" --text="Authentication error, please enter your credentials again:" --add-entry="Username:" --add-password="Password:"  --width=1000 --height=700)

  	username=$(echo $result | awk -F'|' '{print $1}')
  	password=$(echo $result | awk -F'|' '{print $2}')

  	output=$(echo $password | su $username -c whoami)
  done

  return $username
}


crontabDefault=$"# Edit this file to introduce tasks to be run by cron.\n\
#\n\
# Each task to run has to be defined through a single line\n\
# indicating with different fields when the task will be run\n\
# and what command to run for the task\n\
#\n\
# To define the time you can provide concrete values for\n\
# minute (m), hour (h), day of month (dom), month (mon),\n\
# and day of week (dow) or use '*' in these fields (for 'any').\n\
#\n\
# Notice that tasks will be started based on the cron's system\n\
# daemon's notion of time and timezones.\n\
#\n\
# Output of the crontab jobs (including errors) is sent through\n\
# email to the user the crontab file belongs to (unless redirected).\n\
#\n\
# For example, you can run a backup of all your user accounts\n\
# at 5 a.m every week with:\n\
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/\n\
#\n\
# For more information see the manual pages of crontab(5) and cron(8)\n\
#\n\
# m h  dom mon dow   command\n\
"

# Main #
checkPassword
