#!/bin/bash
version=0.0.1

install_location=${HOME}/kiosk-scripts
install_cron=true
install_startup=true
install_wifi_update=true


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

print_value() {
    local name=$1
    local value=$2
    printf "%-30s %s\n" "$name" "$value"
}
done_configuring=false
while ! $done_configuring
do
    install_location=$(get_input_string "Install location" $install_location) 
    install_cron=$(confirm "Install cron to run kiosk from nine to five?" $install_cron)
    install_startup=$(confirm "Install startup scripts in .config/wayfire.ini ?" $install_startup)
    install_wifi_update=$(confirm "Install wifi updater in .config/wayfire.ini ?" $install_wifi_update)
    
    echo These are the values you supplied for the installation:
    echo
    print_value "Intall location" $install_location
    print_value "Install cron for nine to five" $install_cron
    print_value "Install startup script in .config/wayfire.ini" $install_startup
    echo
    done_configuring=$(confirm "Are these values correct?" false)
done

echo installing dependencies
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install waytype crudini unzip

echo installing scripts
tmp_location=/tmp/pi-dashboard-kiosk
wget https://github.com/qwaneu/pi-dashboard-kiosk/archive/refs/heads/main.zip -qO ${tmp_location}.zip
unzip ${tmp_location}.zip -d /tmp
cp -av ${tmp_location}-main/kiosk-scripts ${install_location}

echo installing config
cp -av ${tmp_location}-main/config/pipeline-kiosk ~/.config/pipeline-kiosk

if $install_startup 
then 
    echo installing startup settings
    echo "[autostart]
chromium = bash ${install_location}/dashboard.sh
switchtab = bash ${install_location}/switchtab.sh
screensaver = false
dpms = false" | crudini --merge ${HOME}/.config/wayfire.ini
fi

if $install_wifi_update 
then 
    echo installing wifi updater
    echo "[autostart]
wifi_updater = bash ${install_location}/update-wifi.sh" | crudini --merge ${HOME}/.config/wayfire.ini
fi

if $install_cron
then
    echo installing cron entries for running nine to five
    (crontab -l 2>/dev/null; echo 0 17 * * 1-4 ${install_location}/wakeup_after_hours.sh 16) | crontab -
    (crontab -l 2>/dev/null; echo 0 17 * * 5 ${install_location}/wakeup_after_hours.sh 64) | crontab -
fi

echo done installing
echo summary
echo this is your installation
echo ls -al ${install_location}
echo summary
echo this is your configuration
echo find ${config_dir} -ls
