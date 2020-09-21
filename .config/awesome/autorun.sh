#!/usr/bin/env bash

function run {
  # this checks if the process already has a PID
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

# Programs to run on start-up

run "compton"
