chromium-browser $(cat ~/tabs.txt) \
       --kiosk \
       --noerrdialogs \
       --disable-infobars \
       --no-first-run \
       --ozone-platform=wayland \
       --enable-features=OverlayScrollbar \
       --start-maximized
