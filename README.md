A Dashboard Kiosk based on a Raspberry Pi.

It consists of dashboard.sh, switch.sh and tabs.txt.

* tabs.txt contains a url per line.
* dashboard.sh loads the urls in tabs on chromium
* switch.sh switches between tabs every 20 seconds and reloads the tabs every 5 minutes or so.

## System requirements

* raspberry-pi 4 model b or higher
* assumed to run wayland rather than xorg (although adapting the configuration to xorg shouldn't be hard)

## configuring a Raspberry Pi

Configuring the pi this is still a manual process. But will be developed to be scripted later.

### 1. create an image 
Use the [following documentation to create an image](https://www.raspberrypi.com/documentation/computers/getting-started.html#installing-the-operating-system)
### 2. install packages

Update the packages on the pi. So boot the pi, open a terminal and run:

```bash
sudo apt update
sudo apt upgrade
```
Then install wtype

```bash
sudo apt install wtype
```

### 3. copy scripts to the image

Mount the sd card.

### 4. configure to run dashboard.sh and switch.sh on startup.

Add the following code to the wayfire.ini to start the kiosk and disable powersave and screensaver

file: .config/wayfire.ini

```ini
[autostart]
chromium = bash ~/dashboard.sh
switchtab = bash ~/switchtab.sh
screensaver = false
dpms = false
```
