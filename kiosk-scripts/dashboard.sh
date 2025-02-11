config_dir=~/.config/pipeline-kiosk
tabs_file=${config_dir}/tabs.txt

chromium-browser $(cat ${tabs_file}) \
       --kiosk \
       --noerrdialogs \
       --disable-infobars \
       --no-first-run \
       --ozone-platform=wayland \
       --enable-features=OverlayScrollbar \
       --start-maximized
