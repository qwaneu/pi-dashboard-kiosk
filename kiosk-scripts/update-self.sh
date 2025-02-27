#!/bin/bash
# update-self 
# updates the installation by 
# 1. waiting for the network connection
# 2. getting the new version  (latest tag from git)
# 3. comparing it against the current version (from install.config)
# 4. install the scripts of the newer version if it is higher
config_dir=~/.config/pipeline-kiosk
source ${config_dir}/install.config

network_poll_interval=10

have_network_connection() {
   curl google.com &> /dev/null
}

wait_for_network() {
    while ! have_network_connection  ; do
        sleep network_poll_interval
    done
}

get_latest_version() {
    wget -qO- https://api.github.com/repos/qwaneu/pi-dashboard-kiosk/tags  | jq -r '.[0] .name'
}

update_self() {
    local latest_version="$1"
    local tmp_location=/tmp/pi-dashboard-kiosk
    wget https://github.com/qwaneu/pi-dashboard-kiosk/archive/refs/tags/${latest_version}.zip -qO ${tmp_location}.zip -qO ${tmp_location}.zip
    rm -rf ${tmp_location}-${latest_version}
    unzip ${tmp_location}.zip -d /tmp
    rsync -av --delete ${tmp_location}-${latest_version}/kiosk-scripts/* ${install_location}
    sed -i "s/current_version=.*/current_version=${latest_version}/" ${config_dir}/install.config
}

wait_for_network

latest_version=$(get_latest_version)

if [[ "$latest_version" > "$current_version" ]]; then
    update_self "$latest_version"
fi
