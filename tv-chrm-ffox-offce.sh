#!/bin/sh
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   Install or update to the latest version - Google Chrome -- Installs or updates Google Chrome
#
# SYNOPSIS
#   sudo Install or update to the latest version - Google Chrome
#
####################################################################################################
#
# HISTORY
#
#   Version: 1.1-m
#
#   - 1.0 Martyn Watts, 01.07.2021 Initial Build
#   - 1.1-m Michael Tanner, 18.08.2021 Adapted for Mosyle
#
#
####################################################################################################
# Script to download and install Google Chrome.
#

# Unable to find a reliable web source of the latest version number
# We'll need to download the latest version and extract the version number from the pkg file
url='https://dl.google.com/chrome/mac/stable/gcem/GoogleChrome.pkg'
dnldfile='GoogleChrome.pkg'
appName='Google Chrome'
forceQuit='Y'
logfile="/tmp/GoogleChromeInstallScript.log"
deplog="/tmp/depnotify.log"

open ${logfile}
open ${deplog}
echo "Status: Installing ${appName}" >> ${deplog}

#  To get just the latest version number from the version check URL
/bin/echo "`date`: Downloading latest version." >> ${logfile}
/bin/echo "Downloading latest version."
/usr/bin/curl -o "/tmp/${dnldfile}" ${url}
/bin/echo "`date`: Expanding package." >> ${logfile}
/bin/echo "Expanding package."
pkgutil --expand "/tmp/${dnldfile}" /tmp/pkg
/bin/echo "`date`: Storing latest version data." >> ${logfile}
/bin/echo "Storing latest version data."
latestver=$(cat /tmp/pkg/Distribution | grep 'CFBundleShortVersionString' | cut -f2 -d '"')
/bin/echo "`date`: Removing expanded package" >> ${logfile}
/bin/echo "Removing expanded package."
/bin/rm -rf /tmp/pkg


# Get the version number of the currently-installed App, if any.
	if [[ -e "/Applications/${appName}.app" ]]; then
		currentinstalledver=`/usr/bin/defaults read "/Applications/${appName}.app/Contents/Info" CFBundleShortVersionString`
		echo "Current installed version is: $currentinstalledver"
		echo "Current installed version is: $currentinstalledver" >> ${logfile}
		if [[ ${latestver} = ${currentinstalledver} ]]; then
			echo "${appName} is current. Exiting"
			echo "${appName} is current. Exiting" >> ${logfile}
			exit 0
		fi
	else
		currentinstalledver="none"
		echo "${appName} is not installed"
		echo "${appName} is not installed" >> ${logfile}
	fi


# Compare the two versions, if they are different or the App is not present then download and install the new version.
	if [[ "${currentinstalledver}" != "${latestver}" ]]; then
		/bin/echo "`date`: Current ${appName} version: ${currentinstalledver}" >> ${logfile}
		/bin/echo "Current ${appName} version: ${currentinstalledver}"
		/bin/echo "`date`: Available ${appName} version: ${latestver}" >> ${logfile}
		/bin/echo "Available ${appName} version: ${latestver}"
		/bin/echo "`date`: Force quitting ${appName} if running." >> ${logfile}
		/bin/echo "Force quitting ${appName} if running."

			if [[ "${forceQuit}" = "Y" ]]; then
				killall ${appName}
			fi
		cd /tmp
		   /usr/sbin/installer -pkg ${dnldfile} -target /

		#double check to see if the new version got updated
		newlyinstalledver=`/usr/bin/defaults read "/Applications/${appName}.app/Contents/Info" CFBundleShortVersionString`
		if [[ "${latestver}" = "${newlyinstalledver}" ]]; then
			/bin/echo "`date`: SUCCESS: ${appName} has been updated to version ${newlyinstalledver}" >> ${logfile}
			/bin/echo "SUCCESS: ${appName} has been updated to version ${newlyinstalledver}"
			/bin/echo "`date`: Removing Existing Dock Icon." >> ${logfile}
			/bin/echo "Removing Existing Dock Icon."           
			/usr/local/bin/dockutil --remove "${appName}" --allhomes >> ${logfile}
			/bin/sleep 5
			/bin/echo "`date`: Creating New Dock Icon." >> ${logfile}
			/bin/echo "Creating New Dock Icon."
			#/usr/local/bin/dockutil --add "/Applications/${appName}.app" --after 'Safari' --allhomes >> ${logfile}
			/bin/sleep 3
			/bin/echo "--" >> ${logfile}
		else
			/bin/echo "`date`: ERROR: ${appName} update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
			/bin/echo "ERROR: ${appName} update unsuccessful, version remains at ${currentinstalledver}."
			/bin/echo "--" >> ${logfile}
			exit 1
		fi

	# If App is up to date already, just log it and exit.       
	else
		/bin/echo "`date`: ${appName} is already up to date, running ${currentinstalledver}." >> ${logfile}
		/bin/echo "`date`: ${appName} is already up to date, running ${currentinstalledver}."
		/bin/echo "--" >> ${logfile}
	fi 
	
		/bin/sleep 5
		/bin/echo "`date`: Deleting the downloaded file." >> ${logfile}
		/bin/echo "Deleting the downloaded file."
		/bin/rm /tmp/${dnldfile}
  echo "Command: DeterminateManualStep: 1" >> ${deplog}

echo Chrome Installed
#!/bin/sh
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   FirefoxInstall.sh -- Installs or updates Firefox
#
# SYNOPSIS
#   sudo FirefoxInstall.sh
#
####################################################################################################
#
# HISTORY
#
#   Version: 1.3
#
#   - Joe Farage, 18.03.2015
#   - Chris Hansen, 14.05.2020 Some square brackets change to double square brackets
#   - Martyn Watts, 24.05.2020 Removed Language Variables as they are not needed and results were inconsistent
#   - Martyn Watts, 30.06.2021 Added dock icon for all users using dockutil (prerequisite)
#   - Michael Tanner, 18.08.2021 Adapted for use with Mosyle
#
####################################################################################################
# Script to download and install Firefox.
# Only works on Intel systems.
#

dmgfile="FF.dmg"
logfile="/tmp/FirefoxInstallScript.log"
deplog="/tmp/depnotify.log"

open ${logfile}
echo "Status: Installing Firefox" >> ${deplog}

# Are we running on Intel?
if [ '`/usr/bin/uname -p`'="i386" -o '`/usr/bin/uname -p`'="x86_64" ]; then
	## Get OS version and adjust for use with the URL string
	OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

	## Set the User Agent string for use with curl
	userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

	# Get the latest version of Browser available from Firefox page.
	latestver=`/usr/bin/curl -s -A "$userAgent" https://www.mozilla.org/en-US/firefox/new/ | grep 'data-latest-firefox' | sed -e 's/.* data-latest-firefox="\(.*\)".*/\1/' -e 's/\"//' | /usr/bin/awk '{print $1}'`
	echo "Latest Version is: $latestver"

	# Get the version number of the currently-installed FF, if any.
	if [[ -e "/Applications/Firefox.app" ]]; then
		currentinstalledver=`/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString`
		echo "Current installed version is: $currentinstalledver"
		if [[ ${latestver} = ${currentinstalledver} ]]; then
			echo "Firefox is current. Exiting"
			exit 0
		fi
	else
		currentinstalledver="none"
		echo "Firefox is not installed"
	fi

	url="https://download-installer.cdn.mozilla.net/pub/firefox/releases/${latestver}/mac/en-US/Firefox%20${latestver}.dmg"
	echo "Latest version of the URL is: $url"
	echo "`date`: Download URL: $url" >> ${logfile}

	# Compare the two versions, if they are different or Firefox is not present then download and install the new version.
	if [[ "${currentinstalledver}" != "${latestver}" ]]; then
		/bin/echo "`date`: Current Firefox version: ${currentinstalledver}" >> ${logfile}
		/bin/echo "`date`: Available Firefox version: ${latestver}" >> ${logfile}
		/bin/echo "`date`: Downloading newer version." >> ${logfile}
		/usr/bin/curl -s -o /tmp/${dmgfile} ${url}
		/bin/echo "`date`: Mounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
		/bin/echo "`date`: Installing..." >> ${logfile}
		ditto -rsrc "/Volumes/Firefox/Firefox.app" "/Applications/Firefox.app"

		/bin/sleep 10
		/bin/echo "`date`: Unmounting installer disk image." >> ${logfile}
		/usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep Firefox | awk '{print $1}') -quiet
		/bin/sleep 10
		/bin/echo "`date`: Deleting disk image." >> ${logfile}
		/bin/rm /tmp/${dmgfile}

		#double check to see if the new version got updated
		newlyinstalledver=`/usr/bin/defaults read /Applications/Firefox.app/Contents/Info CFBundleShortVersionString`
		if [[ "${latestver}" = "${newlyinstalledver}" ]]; then
			/bin/echo "`date`: SUCCESS: Firefox has been updated to version ${newlyinstalledver}" >> ${logfile}
			/bin/echo "`date`: Creating Dock Icon." >> ${logfile}
			#/usr/local/bin/dockutil --remove 'Firefox' --allhomes
			/bin/sleep 3
			#/usr/local/bin/dockutil --add '/Applications/Firefox.app' --after 'Safari' --allhomes
	   # /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -title "Firefox Installed" -description "Firefox has been updated." &
		else
			/bin/echo "`date`: ERROR: Firefox update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
			/bin/echo "--" >> ${logfile}
			exit 1
		fi

	# If Firefox is up to date already, just log it and exit.       
	else
		/bin/echo "`date`: Firefox is already up to date, running ${currentinstalledver}." >> ${logfile}
		/bin/echo "--" >> ${logfile}
	fi  
else
	/bin/echo "`date`: ERROR: This script is for Intel Macs only." >> ${logfile}
fi
echo "Command: DeterminateManualStep: 1" >> ${deplog}

echo Firefox Installed

logfile="/tmp/OfficeInstallScript.log"
open ${logfile}
cd /tmp
echo Downloading MS Office Installer >> ${logfile}
sudo curl -o /tmp/office-install.sh https://raw.githubusercontent.com/PurpleComputing/mdmscripts/main/office-install.sh  >> /tmp/purple-officeinstall.log
echo Giving Permissions >> ${logfile}
sudo chmod +x /tmp/office-install.sh
echo Installing Office >> ${logfile}
sudo /tmp/office-install.sh full >> ${logfile}
logfile="/tmp/OfficeInstallScript.log"
echo Verifying Install >> ${logfile}
sleep 60s
echo Cleaning Up Files >> ${logfile}
sudo rm -rf /tmp/office-install.sh >> ${logfile}
echo Office Install Completed. >> ${logfile}

echo Installed Chrome Firefox and Office >> ${deplog}
