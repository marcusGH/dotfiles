#!/usr/bin/env bash

# order of the monitors from left to right
MONITORS=(1 0 2)
# which monitors are rotated?
ROTATED=4
# primary monitor
PRIMARY=2
# monitor to turn off
OFF=1

# get a list of the available displays as a space-separated string
output=$(xrandr | grep -P '^(?=([^ ]+ connected))(?=(?!Screen \d:)).*$' | sort | awk '{print $(1);}')

# split the string by spaces
displays=()
for d in $output
do
    displays+=($d)
done

# print log
echo "Found ${#displays[@]} displays:"
for ((i=0; i<${#displays[@]}; i++)); do
    echo "  $i -> ${displays[$i]}"
done

# exit if only one monitor
if ((${#displays[@]} == 1)) ; then
    echo "Found only one monitor. Doing nothing...";
    exit 1;
fi

# make the command
COMMAND="xrandr"
for ((i=0; i<${#displays[@]}; i++)); do
    # base command
    COMMAND="${COMMAND} --output ${displays[${MONITORS[$i]}]} "
    # maybe primary?
    if (($PRIMARY == ${MONITORS[$i]})) ; then
        COMMAND="${COMMAND} --primary "
    fi
    # maybe rotate?
    if (($ROTATED == ${MONITORS[$i]})) ; then
        COMMAND="${COMMAND} --rotate left "
    else
        COMMAND="${COMMAND} --rotate normal "
    fi
    # don't align to the next monitors if on last monitor
    if (($i<${#displays[@]} - 1)) ; then
        # do input sanitation
        if ((${MONITORS[$i]} >= ${#displays[@]})) \
            || ((${MONITORS[$i + 1]} >= ${#displays[@]})) ; then
            echo "The ${i}th or ${i+1} entry in MONITORS is invalid: ${MONITORS[$i]} ${MONITORS[${i+1}]}"
            exit 1
        fi
        # rest of command
        COMMAND="${COMMAND} --left-of ${displays[${MONITORS[$i + 1]}]}"
    fi
    # turn the monitor off?
    if (($OFF == ${MONITORS[$i]})) ; then
        COMMAND="${COMMAND} --off"
    fi
done

# run the command
echo "Running the command:
  ${COMMAND}"
$COMMAND

# only do something if there are multiple screens
# if ((${#displays[@]} == 3)) ; then
#     c="xrandr --output ${displays[2]} --primary --right-of ${displays[0]} \
#               --output ${displays[0]} --right-of ${displays[1]}"
#     echo "Running the command: $c"
#     $c
# elif ((${#displays[@]} == 2)) ; then
#     c="xrandr --output ${displays[1]} --primary --right-of ${displays[0]}"
#     echo "Running the command: $c"
#     $c
# elif ((${#displays[@]} == 1))
# then
#     echo "Doing nothing"
# else
#     echo "Not sure what to do..."
# fi
