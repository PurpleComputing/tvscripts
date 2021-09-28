#!/bin/sh
#####################################################################################################
#                                                                                                   #
# ABOUT THIS PROGRAM                                                                                #
#                                                                                                   #
# NAME                                                                                              #
#   Install the latest versions of Google Chrome, Firefox and Full MS Office Suite                  #
#                                                                                                   #
# SYNOPSIS                                                                                          #
#   sudo tv-chrm-ffox-office.sh                                                                     #
#                                                                                                   #
#####################################################################################################
#                                                                                                   #
#  History                                                                                          #
#                                                                                                   #
#   Version: 1.2                                                                                    #
#                                                                                                   #
#   - 1.0 Martyn Watts, 01.07.2021 Initial Build                                                    #
#   - 1.1-m Michael Tanner, 18.08.2021 Adapted for Mosyle                                           #
#   - 1.2 Martyn Watts, 28.09.2021 Removed the duplicated scripts in favour of calling              #
#                                  the main ones sequentially                                       #
#                                                                                                   #
#                                                                                                   #
#####################################################################################################


#####################################################################################################
# Install Chrome                                                                                    #
#####################################################################################################
sudo curl -o /tmp/google-chrome.sh https://raw.githubusercontent.com/PurpleComputing/mdmscripts/main/google-chrome.sh
sudo chmod +x /tmp/google-chrome.sh
sudo /tmp/google-chrome.sh openconsole

#####################################################################################################
# Install Firefox                                                                                   #
#####################################################################################################
sudo curl -o /tmp/Firefox.sh https://raw.githubusercontent.com/PurpleComputing/mdmscripts/main/Firefox.sh
sudo chmod +x /tmp/Firefox.sh
sudo /tmp/Firefox.sh openconsole

#####################################################################################################
# Install Full MS Office Suite                                                                      #
#####################################################################################################
sudo curl -o /tmp/microsoft-apps.sh https://raw.githubusercontent.com/PurpleComputing/mdmscripts/main/microsoft-apps.sh
sudo chmod +x /tmp/microsoft-apps.sh
sudo /tmp/microsoft-apps.sh full-oc
