#!/bin/bash

# This script checkt the nework connection. If it is not available, 
# it edits the connection based on the month

config_dir=~/.config/pipeline-kiosk
source ${config_dir}/wifi.config
monthly_wifi_credentials_file=${config_dir}/wifi-credentials.txt

edit_connection() {
        local username=$1
        local password=$2s
        sudo sed -i -e "s/identity=.*/identity=${username}/" \
                -e "s/password=.*/password=${password}/" \
                "/etc/NetworkManager/system-connections/${connection_name}.nmconnection"
}

connection_parameters() {
   echo $(sed "$(date +%m)q;d" ${monthly_wifi_credentials_file})
}

have_network_connection() {
   curl google.com &> /dev/null
}

restart_networking() {
   sudo systemctl restart NetworkManager
}

#
# Main 
#
if [[ ${monitor_wifi} != true ]]
then 
   exit 0
fi

if ! have_network_connection
then
   edit_connection $(connection_parameters)
   restart_networking
fi