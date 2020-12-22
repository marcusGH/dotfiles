#!/usr/bin/env bash

# get a list of the available displays as a space-separated string
output=$(xrandr | grep -P '^(?=([^ ]+ connected))(?=(?!Screen \d:)).*$' | sort | awk '{print $(1);}')

# split the string by spaces
displays=()
for d in $output
do
    displays+=($d)
done

# log
echo "Found ${#displays[@]} displays: ${displays[@]}."

# only do something if there are multiple screens
if ((${#displays[@]} == 3)) ; then
    c="xrandr --output ${displays[2]} --primary --right-of ${displays[0]} \
              --output ${displays[0]} --right-of ${displays[1]}"
    echo "Running the command: $c"
    $c
elif ((${#displays[@]} == 2)) ; then
    c="xrandr --output ${displays[1]} --primary --right-of ${displays[0]}"
    echo "Running the command: $c"
    $c
elif ((${#displays[@]} == 1))
then
    echo "Doing nothing"
else
    echo "Not sure what to do..."
fi
