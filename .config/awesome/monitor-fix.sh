#!/usr/bin/env bash

# get a list of the available displays as a space-separated string
output=$(xrandr | grep -P '^(?=[^ ]+)(?=(?!Screen \d:)).*$' | awk '{print $(1);}')

# split the string by spaces
displays=()
for d in $output
do
    displays+=($d)
done

# only do something if there are multiple screens
if ((${#displays[@]} == 2))
then
    echo "Found two displays: ${displays[0]} and ${displays[1]}."
    c="xrandr --output ${displays[0]} --primary --right-of ${displays[1]}"
    echo "Running the command: $c"
    $c
elif ((${#displays[@]} == 1))
then
    echo "Only found one display: ${displays[0]}."
    echo "Doing nothing"
else
    echo "Found ${#displays[@]} displays, not sure what to do..."
fi
