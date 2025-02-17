A Dashboard Kiosk based on a Raspberry Pi.

It started out as dashboard.sh, switch-tab.sh and tabs.txt
but it is a little bit more now it supports:

* running from 9 to 5 and going down at night
* installation using an installation script
* cycling through wifi connections every month
* self updates based on git tags

## The basics

dashboard.sh opens chromium in kiosk mode with a tab for each url in ~/.config/pipeline-kiosk/tabs.txt. switch-tabs.sh cycles through the browser tabs and refreshes 
all tabs once in a while. 

### Why switch-tabs.sh rather than a browserplugin?

Browser plugins:
* are an extra dependency
* will go end of life afer some time
* do generally not support refreshing the tabs once in a while

We need the latter, to make sure the browsertab's session is kept open.

## Installing 
On your pi run

```bash
https://raw.githubusercontent.com/qwaneu/pi-dashboard-kiosk/refs/heads/main/kiosk-scripts/install.sh
chmod +x install.sh
./install.sh
```

Then follow instructions.

## System requirements

* raspberry-pi 4 model b or higher
* assumed to run wayland rather than xorg (although adapting the configuration to xorg shouldn't be hard)


## Configuring the pi
Configuring the pi this is still a manual process. But will be developed to be scripted later.


### 1. create an image 
Use the [following documentation to create an image](https://www.raspberrypi.com/documentation/computers/getting-started.html#installing-the-operating-system)


### 2. install run the installation

See installing

