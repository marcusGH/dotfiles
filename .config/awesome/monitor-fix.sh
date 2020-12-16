#!/usr/bin/env bash

# get a list of the available displays as a space-separated string
output=$(xrandr | grep -P '^(?=([^ ]+ connected))(?=(?!Screen \d:)).*$' | awk '{print $(1);}')

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
    c="xrandr --output ${displays[0]} --primary --right-of ${displays[1]} \
              --output ${displays[1]} --right-of ${displays[2]}"
    echo "Running the command: $c"
    $c
elif ((${#displays[@]} == 2)) ; then
    c="xrandr --output ${displays[0]} --primary --right-of ${displays[1]}"
    echo "Running the command: $c"
    $c
elif ((${#displays[@]} == 1))
then
    echo "Doing nothing"
else
    echo "Not sure what to do..."
fi
