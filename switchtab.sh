#!/bin/bash
initial_wait=60		# initial wait after detecting chromium
initial_time_per_tab=30 # initial time per tab - to get them up and runnning
normal_time_per_tab=20  # normal time for a tab to be visual
chrome_poll_interval=5  # polling interval to detect chromium
number_of_tabs=$(cat tabs.txt | wc -l)
switches=0

export XDG_RUNTIME_DIR=/run/user/1000

get_chromium_pid() {
   pgrep chromium | head -1
}

wait_for_chrome() {
  local chromium_pid=$(get_chromium_pid)

  while [[ -z ${chromium_pid} ]]
  do 
    echo Waiting for Chromium
    sleep $chrome_poll_interval
    chromium_pid=$(get_chromium_pid)
  done

  echo Chromium browser pid: ${chromium_pid}
}

switch_tab() {
  echo switch $SECONDS
  wait_for_chrome
  wtype -M ctrl -P tab # press ctrl-tab
  wtype -m ctrl -p tab # release ctrl-tab
}

refresh() {
  echo refresh $SECONDS
  wait_for_chrome
  wtype -M ctrl -P r # press r
  wtype -m ctrl -p r # release r
}

refresh_all_tabs() {
  echo refreshing_all_tabs
  for i in $(seq 1 ${number_of_tabs})
  do
    refresh
    sleep ${initial_time_per_tab}
    switch_tab
  done
}
refresh_interval=300
refresh_if_necessary() {
  if (( SECONDS % refresh_interval == 0 ))
  then
    refresh_all_tabs
  fi
}

switch_if_necessary() {
  if (( SECONDS %  == normal_time_per_tab )) 
  then 
    switch_tab
  fi
}



wait_for_chrome
sleep $initial_wait
refresh_all_tabs
while true
do
  switch_if_necessary
  refresh_if_necessary
  sleep 1
done

