#!/bin/bash
# this script installs the kiosk interactively

install_location=${HOME}/kiosk-scripts
config_dir=${HOME}/.config
pipeline_kiosk_config=${config_dir}/pipeline-kiosk
install_cron=true
install_startup=true
install_wifi_update=true
wifi_connection_to_update=""

get_input_string() {
    local prompt=$1
    local default_value=$2
    read -p "${prompt} (${default_value}): " value
    value=$(echo $value | xargs)
    if [[ $value ]]
    then
        echo $value
    else
        echo $default_value
    fi
}

confirm() {
    local prompt=$1
    local default_value=$2
    local default_value_indicator=$($default_value && echo "Y/n" || echo "y/N")
    read -p "${prompt} (${default_value_indicator}): " value
    value=$(echo $value | xargs)
    case "$value" in
        ([yY]) echo true ;;
        ([nN]) echo false ;;
        (*) echo $default_value;;
    esac
}


list_connections() {
        # Initialize an empty array
        local -n list=$1
        local directory="/etc/NetworkManager/system-connections"

        # Use find to get the list of connections and read them into the array
        while IFS= read -r -d '' file; do
                connection=$(basename "$file" | sed 's/\.[^.]*$//')
            list+=("$connection")
        done < <(find "$directory" -maxdepth 1 -type f -print0)
        printf "%s\n" "${connection_list[@]}"
}

print_value() {
    local name=$1
    local value=$2
    printf "%-30s %s\n" "$name" "$value"
}

note() {
    local str="$@"
    local padded_length=$((80 - ${#str}))
    echo "${str}" $(printf "%${padded_length}s" | tr ' ' '=')
}

# configure choices
done_configuring=false
while ! $done_configuring
do
    install_location=$(get_input_string "Install location" $install_location) 
    install_cron=$(confirm "Install cron to run kiosk from nine to five?" $install_cron)
    install_startup=$(confirm "Install startup scripts in ${config_dir}/wayfire.ini ?" $install_startup)
    install_wifi_update=$(confirm "Install wifi updater in ${config_dir}/wayfire.ini ?" $install_wifi_update)
    if $install_wifi_update 
    then
        connection_list=()
        list_connections connection_list
        select connection in "${connection_list[@]}"; do
            if [[ -n "${connection}" ]]; then
                wifi_connection_to_update="$connection"
                break
            else
                echo illegal choice
            fi
        done
    fi
    
    echo These are the values you supplied for the installation:
    echo
    print_value "Intall location" $install_location
    print_value "Install cron for nine to five" $install_cron
    print_value "Install startup script in .config/wayfire.ini" $install_startup
    print_value "Install update wifi connetions" $install_wifi_update
    [[ $install_wifi_update ]] && print_value "Wifi connection to update" "$wifi_connection_to_update"
    echo
    done_configuring=$(confirm "Are these values correct?" false)
done

# Installing
note installing dependencies
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install wtype crudini unzip cron jq rsync

note installing scripts
tmp_location=/tmp/pi-dashboard-kiosk
wget https://github.com/qwaneu/pi-dashboard-kiosk/archive/refs/heads/main.zip -qO ${tmp_location}.zip

unzip ${tmp_location}.zip -d /tmp
cp -avT ${tmp_location}-main/kiosk-scripts ${install_location}

note installing config
cp -anvT ${tmp_location}-main/config/pipeline-kiosk ${pipeline_kiosk_config}
sed -i "s,install_location.*,install_location=${install_location}," ${pipeline_kiosk_config}/install.config

if $install_startup 
then 
    note installing startup settings in wayfire.ini
    echo "[autostart]
chromium = bash ${install_location}/dashboard.sh
switchtab = bash ${install_location}/switchtab.sh
updateself = bash ${install_location}/update-self.sh
screensaver = false
dpms = false" | crudini --merge ${HOME}/.config/wayfire.ini
fi

if $install_wifi_update 
then 
    note installing wifi updater in wayfire.ini
    echo "[autostart]
wifi_updater = bash ${install_location}/update-wifi.sh" | crudini --merge ${HOME}/.config/wayfire.ini
    
    sed -i 's/^monitor_wifi.*$/monitor_wifi=true/' ${pipeline_kiosk_config}/wifi.config
    sed -i "s/^connection_name.*$/connction_name=\"${wifi_connection_to_update}\"/" ${pipeline_kiosk_config}/wifi.config
fi

if $install_cron
then
    note installing cron entries for running nine to five
    (crontab -l 2>/dev/null; echo "0 17 * * 1-4 ${install_location}/wakeup_after_hours.sh 16") | crontab -
    (crontab -l 2>/dev/null; echo "0 17 * * 5 ${install_location}/wakeup_after_hours.sh 64") | crontab -
fi

# showing results
note done installing
note summary
note this is your installation
find ${install_location}/ -ls
echo
note this is your wayfire.ini
cat ${config_dir}/wayfire.ini
echo
note this is your configuration
find ${config_dir}/pipeline-config/ -ls
echo
note wifi config
cat ${pipeline_kiosk_config}/wifi.config
note install config
cat ${pipeline_kiosk_config}/install.config
echo
note this is your crontab
crontab -l
echo 
note "="
note TODO:
echo edit ${config_dir}/pipeline-config/tabs.txt to contain your tabs
echo edit ${config_dir}/pipeline-config/wifi-credentials.txt to contain credentials for each month
