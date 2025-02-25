config_dir=~/.config/pipeline-kiosk
tabs_file=${config_dir}/tabs.txt

while true
do 
        chromium-browser $(cat ${tabs_file}) \
               --kiosk \
               --noerrdialogs \
               --disable-infobars \
               --no-first-run \
               --ozone-platform=wayland \
               --enable-features=OverlayScrollbar \
               --start-maximized &
        pid=$(pgrep chromium | head -1)
        wait $pid
done
