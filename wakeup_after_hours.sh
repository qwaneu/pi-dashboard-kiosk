#!/bin/bash
echo going down, restarting in $1 hours
seconds=$(( $1 * 3600 ))
sudo echo +$seconds | sudo tee /sys/class/rtc/rtc0/wakealarm
sudo halt
