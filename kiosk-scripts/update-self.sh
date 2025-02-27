#!/bin/bash

config_dir=~/.config/pipeline-kiosk
source ${config_dir}/install.config

network_poll_interval=10

have_network_connection() {
   curl google.com &> /dev/null
}

wait_for_network() {
    while ! have_network_connection() {
        sleep network_poll_interval
    }
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

latest_version=$(get_latest_version)

wait_for_network

if [[ "$latest_version" > "$current_version" ]]; then
    update_self "$latest_version"
fi
