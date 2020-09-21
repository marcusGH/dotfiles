#!/usr/bin/env bash
if [ $# -eq 0 ]
then
	echo "You must specify a percentage"
fi

if (( $(echo "$1 < 0.0" | bc -l) )) || (( $(echo "$1 > 1.0" | bc -l) ))
then
	echo "You must input a number between 0 and 1"
else
	max_brightness=$(< /sys/class/backlight/intel_backlight/max_brightness)
	current_brightness=$(< /sys/class/backlight/intel_backlight/brightness)
	new_brightness=$(printf "%.0f" "$(echo "$1 * $max_brightness" | bc -l)")
	echo "Changed brightness from $current_brightness to $new_brightness."
	sudo echo "$new_brightness" > /sys/class/backlight/intel_backlight/brightness
fi
