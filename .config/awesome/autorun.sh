#!/usr/bin/env bash

function run {
  # this checks if the process already has a PID
  if ! pgrep -f $1 ;
  then
    $@&
  fi
}

# Programs to run on start-up

# screen compositor
run compton
# caps ctrl when held down, Esc when pressed
run setxkbmap -option 'caps:ctrl_modifier'
# ctrl as esc when pressed and remains ctrl modifier when held down
run xcape -e 'Caps_Lock=Escape;Control_L=Escape'
